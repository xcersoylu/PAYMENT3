  METHOD create_clearing_document.
    TYPES : BEGIN OF ty_local_time_info,
              timestamp TYPE timestamp,
              date      TYPE d,
              time      TYPE t,
            END OF ty_local_time_info.
    DATA lt_aparitems TYPE ypym_journal_entry_cleari_tab3.
    DATA ls_partial TYPE ypym_amount.
    DATA ls_local_time_info TYPE ty_local_time_info.
    DATA lv_referencedocumentitem TYPE ypym_journal_entry_clearing_r5-reference_document_item.
    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_comm_arrangement(
          comm_scenario  = 'YCS_PYM_CLEARING' "VALUE #( lt_parameters[ parameter_key = 'COMM_SCENARIO' ]-parameter_value OPTIONAL )
        ).
        DATA(lo_proxy) = NEW ypym_co_journal_entry_bulk_cle( destination = destination ).
        DATA(ls_request) = VALUE ypym_journal_entry_bulk_cleari( ).

        GET TIME STAMP FIELD DATA(lv_ts).
        TRY.
            DATA(lv_tz) = cl_abap_context_info=>get_user_time_zone(  ) .
            CONVERT TIME STAMP lv_ts TIME ZONE lv_tz INTO DATE ls_local_time_info-date TIME ls_local_time_info-time.
            CONVERT DATE ls_local_time_info-date TIME ls_local_time_info-time INTO TIME STAMP ls_local_time_info-timestamp TIME ZONE 'UTC'.
          CATCH cx_abap_context_info_error.
        ENDTRY.
        IF mv_profit_center = abap_true.
*faturanın satıcı kalemi ya da kalemleri bulunuyor.
          SELECT * FROM i_operationalacctgdocitem WHERE companycode = @is_item-companycode
                                                    AND  accountingdocument = @is_item-accountingdocument
                                                    AND fiscalyear = @is_item-fiscalyear
                                                    AND financialaccounttype = 'K'
                                                    AND supplier = @is_item-supplier
           INTO TABLE @DATA(lt_invoice_supplier_items).
*ödeme belgesinin satıcı kalemleri
          SELECT * FROM i_operationalacctgdocitem WHERE companycode = @is_item-companycode
                                                    AND accountingdocument = @is_item-paymentdocument
                                                    AND fiscalyear = @is_item-paymentdocumentyear
                                                    AND financialaccounttype = 'K'
                                                    AND supplier = @is_item-supplier
           INTO TABLE @DATA(lt_payment_items).
*faturanın satıcı kalemleri
          lv_referencedocumentitem = 0.
          LOOP AT lt_invoice_supplier_items INTO DATA(ls_invoice_supplier_item).
            lv_referencedocumentitem += 1.
            APPEND VALUE #( reference_document_item = lv_referencedocumentitem
                            company_code = is_item-companycode
                            account_type = 'K'
                            aparaccount  = is_item-supplier
                            fiscal_year  = is_item-fiscalyear
                            accounting_document = is_item-accountingdocument
                            accounting_document_item = ls_invoice_supplier_item-accountingdocumentitem
                           ) TO lt_aparitems.
          ENDLOOP.
*ödeme belgesinin satıcı kalemleri
          LOOP AT lt_payment_items INTO DATA(ls_paymentitem).
            lv_referencedocumentitem += 1.
            APPEND VALUE #( reference_document_item = lv_referencedocumentitem
                            company_code = is_item-companycode
                            account_type = 'K'
                            aparaccount  = is_item-supplier
                            fiscal_year  = is_item-paymentdocumentyear
                            accounting_document = is_item-paymentdocument
                            accounting_document_item = ls_paymentitem-accountingdocumentitem
                           ) TO lt_aparitems.
          ENDLOOP.
        ELSE.
*kısmi ödeme mi ?
          IF is_item-paymentamount <> is_item-absoluteamountintransaccrcy.
            ls_partial =  VALUE #( currency_code = is_item-transactioncurrency
                                   content = is_item-absoluteamountintransaccrcy - is_item-paymentamount ).
          ENDIF.
          APPEND VALUE #( company_code = is_item-companycode
                          account_type = 'K'
                          aparaccount  = is_item-supplier
                          fiscal_year  = is_item-documentdate(4)
                          accounting_document = is_item-accountingdocument
                          accounting_document_item = is_item-accountingdocumentitem
                         ) TO lt_aparitems.
          IF ls_partial IS INITIAL.
            APPEND VALUE #( company_code = is_item-companycode
                            account_type = 'K'
                            aparaccount  = is_item-supplier
                            fiscal_year  = is_item-paymentdocumentyear
                            accounting_document = is_item-paymentdocument
                            accounting_document_item = '002' "müşteri kalemi 2. kalem olduğu için
                           ) TO lt_aparitems.
          ELSE.
            APPEND VALUE #( company_code = is_item-companycode
                            account_type = 'K'
                            aparaccount  = is_item-supplier
                            fiscal_year  = is_item-paymentdocumentyear
                            accounting_document = is_item-paymentdocument
                            accounting_document_item = '002' "müşteri kalemi 2. kalem olduğu için
                            other_deduction_amount_in_dsp = ls_partial
                           ) TO lt_aparitems.
          ENDIF.
        ENDIF.
        APPEND VALUE #( message_header = VALUE #( id = VALUE #( content = 'PYM_CLEARING' )
                                                                            creation_date_time = ls_local_time_info-timestamp )
                        journal_entry = VALUE #( company_code              = is_item-companycode
                                                 accounting_document_type  = COND #( WHEN mv_clearingdocumenttype IS INITIAL THEN 'KZ' ELSE mv_clearingdocumenttype )
                                                 document_date             = ls_local_time_info-date
                                                 posting_date              = ls_local_time_info-date
                                                 currency_code             = is_item-transactioncurrency
                                                 document_header_text      = |{ is_item-accountingdocument }/{ is_item-paymentdocument }|
                                                 created_by_user           = cl_abap_context_info=>get_user_technical_name(  )
                                                aparitems                 = lt_aparitems ) ) TO
       ls_request-journal_entry_bulk_clearing_re-journal_entry_clearing_request.
        ls_request-journal_entry_bulk_clearing_re-message_header = VALUE #( id = VALUE #( content = 'PYM_CLEARING' )
                                                                             creation_date_time = ls_local_time_info-timestamp ).
        lo_proxy->journal_entry_bulk_clearing_re(
          EXPORTING
            input = ls_request
        ).
        COMMIT WORK.

        DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
        DO 5 TIMES.
          SELECT SINGLE clearingjournalentry FROM i_journalentryitem WITH PRIVILEGED ACCESS
                      WHERE clearingjournalentry IS NOT INITIAL
                        AND accountingdocument = @is_item-paymentdocument
                        AND companycode        = @is_item-companycode
                        AND fiscalyear         = @is_item-paymentdocumentyear
                        AND sourceledger       = '0L'
                        AND ledger             = '0L'
                        AND financialaccounttype = 'K'
                        INTO @DATA(lv_clearing_document).
          IF sy-subrc = 0.
            ev_accountingdocument = lv_clearing_document.
            ev_fiscalyear = is_item-paymentdocumentyear.
            EXIT.
          ELSE.
            WAIT UP TO 1 SECONDS.
          ENDIF.
        ENDDO.

      CATCH cx_soap_destination_error.
      CATCH cx_ai_system_fault.
        " handle error
    ENDTRY.

  ENDMETHOD.
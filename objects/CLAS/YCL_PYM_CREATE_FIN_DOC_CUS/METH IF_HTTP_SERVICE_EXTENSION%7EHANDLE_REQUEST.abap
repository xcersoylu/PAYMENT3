  METHOD if_http_service_extension~handle_request.

    TYPES : BEGIN OF ty_currencyamount,
              currencyrole           TYPE string,
              journalentryitemamount TYPE ypym_e_wrbtr,
              currency               TYPE waers,
              taxamount              TYPE ypym_e_wrbtr,
              taxbaseamount          TYPE ypym_e_wrbtr,
            END OF ty_currencyamount.
    TYPES tt_currencyamount TYPE TABLE OF ty_currencyamount WITH EMPTY KEY.
    TYPES : BEGIN OF ty_glitem,
              glaccountlineitem             TYPE string,
              glaccount                     TYPE saknr,
              assignmentreference           TYPE dzuonr,
              reference1idbybusinesspartner TYPE xref1,
              reference2idbybusinesspartner TYPE xref2,
              reference3idbybusinesspartner TYPE xref3,
              costcenter                    TYPE kostl,
              orderid                       TYPE aufnr,
              documentitemtext              TYPE sgtxt,
              specialglcode                 TYPE ypym_e_umskz,
              taxcode                       TYPE mwskz,
              profitcenter                  TYPE prctr,
              _currencyamount               TYPE tt_currencyamount,
            END OF ty_glitem,
            BEGIN OF ty_aritems, "kunnr
              glaccountlineitem             TYPE string,
              customer                      TYPE kunnr,
              glaccount                     TYPE hkont,
              paymentmethod                 TYPE dzlsch,
              paymentterms                  TYPE dzterm,
              assignmentreference           TYPE dzuonr,
              profitcenter                  TYPE prctr,
              creditcontrolarea             TYPE kkber,
              reference1idbybusinesspartner TYPE xref1,
              reference2idbybusinesspartner TYPE xref2,
              reference3idbybusinesspartner TYPE xref3,
              documentitemtext              TYPE sgtxt,
              specialglcode                 TYPE ypym_e_umskz,
              _currencyamount               TYPE tt_currencyamount,
            END OF ty_aritems.
    DATA lt_je             TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.
    DATA lt_glitem         TYPE TABLE OF ty_glitem.
    DATA lt_aritem         TYPE TABLE OF ty_aritems.
    DATA lv_glaccountlineitem TYPE n LENGTH 3.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    LOOP AT ms_request-items INTO DATA(ls_item) WHERE paymentstatus <> '01'.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 009 INTO DATA(lv_message).
      APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
    ENDIF.
    IF ms_response-messages IS INITIAL.
      SELECT SINGLE value FROM ypym_t_parameter WHERE parametername = 'CUSTOMER'
                                                  AND parameterkey = 'CLEARING_DOCUMENT_TYPE'
      INTO @mv_clearingdocumenttype.
      SELECT SINGLE value FROM ypym_t_parameter WHERE parametername = 'CUSTOMER'
                                                  AND parameterkey = 'PAYMENT_DOCUMENT_TYPE'
      INTO @mv_paymentdocumenttype.
      SELECT SINGLE value FROM ypym_t_parameter WHERE parametername = 'ACCOUNTING_DOCUMENT'
                                                 AND parameterkey = 'PROFIT_CENTER'
      INTO @mv_profit_center.
      IF mv_profit_center = abap_true.
        SELECT jeitem~companycode,
               jeitem~accountingdocument,
               jeitem~accountingdocumentitem,
               jeitem~fiscalyear,
               jeitem~customer,
               jeitem~profitcenter,
               jeitem~amountintransactioncurrency
        FROM @ms_request-items AS items INNER JOIN i_journalentryitem AS jeitem ON jeitem~companycode = items~companycode
                                                                               AND jeitem~accountingdocument = items~accountingdocument
                                                                               AND jeitem~fiscalyear = items~fiscalyear
                                                                               AND jeitem~customer = items~customer
        WHERE jeitem~sourceledger = '0L'
          AND jeitem~ledger = '0L'
          AND jeitem~financialaccounttype = 'S'
        INTO CORRESPONDING FIELDS OF TABLE @mt_profitcenter.
*ÖDK lı kayıtlar buradan gelmiyor aşağıda bulunuyor.
        SELECT opitem~companycode,
               opitem~accountingdocument,
               opitem~accountingdocumentitem,
               opitem~fiscalyear,
               opitem~customer,
               opitem~profitcenter,
               opitem~amountintransactioncurrency,
               'X' AS bsegline,
               opitem~glaccount
          FROM @ms_request-items AS items
          INNER JOIN i_operationalacctgdocitem AS opitem
            ON opitem~companycode        = items~companycode
           AND opitem~accountingdocument = items~accountingdocument
           AND opitem~fiscalyear         = items~fiscalyear
           AND opitem~customer           = items~customer
         WHERE opitem~financialaccounttype = 'K'
           AND NOT EXISTS (
               SELECT *
                 FROM i_journalentryitem AS jeitem
                WHERE jeitem~companycode        = items~companycode
                  AND jeitem~accountingdocument = items~accountingdocument
                  AND jeitem~fiscalyear         = items~fiscalyear
                  AND jeitem~customer           = items~customer
                  AND jeitem~sourceledger       = '0L'
                  AND jeitem~ledger             = '0L'
                  AND jeitem~financialaccounttype = 'S'
           )
         APPENDING CORRESPONDING FIELDS OF TABLE @mt_profitcenter.
      ENDIF.

      LOOP AT ms_request-items ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item>-paymentdocument IS INITIAL.
          APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<fs_je>).
          TRY.
              <fs_je>-%cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
              IF mv_profit_center = abap_true.
                lv_glaccountlineitem = '001'.
                LOOP AT mt_profitcenter INTO DATA(ls_profitcenter) WHERE companycode = <ls_item>-companycode
                                                                     AND accountingdocument = <ls_item>-accountingdocument
                                                                     AND fiscalyear = <ls_item>-fiscalyear
                                                                     AND customer = <ls_item>-customer.
                  APPEND VALUE #( glaccountlineitem             = lv_glaccountlineitem
                                  glaccount                     = <ls_item>-glaccount
                                  documentitemtext              = <ls_item>-customername
                                  profitcenter                  = ls_profitcenter-profitcenter
                                  _currencyamount = VALUE #( ( currencyrole = '00'
                                                              journalentryitemamount = -1 * abs( ls_profitcenter-amountintransactioncurrency )
                                                              currency = <ls_item>-transactioncurrency  ) )          ) TO lt_glitem.
                  lv_glaccountlineitem += 1.
                ENDLOOP.
                LOOP AT mt_profitcenter INTO ls_profitcenter WHERE companycode = <ls_item>-companycode
                                                               AND accountingdocument = <ls_item>-accountingdocument
                                                               AND fiscalyear = <ls_item>-fiscalyear
                                                               AND customer = <ls_item>-customer.
                  IF ls_profitcenter-bsegline IS INITIAL.
                    APPEND VALUE #( glaccountlineitem             = lv_glaccountlineitem
                                    customer                      = <ls_item>-customer
                                    documentitemtext              = 'Havale'
                                    profitcenter                  = ls_profitcenter-profitcenter
                                    _currencyamount = VALUE #( ( currencyrole = '00'
                                                               journalentryitemamount = abs( ls_profitcenter-amountintransactioncurrency )
                                                               currency = <ls_item>-transactioncurrency  ) ) ) TO lt_aritem.
                  ELSE.
                    APPEND VALUE #( glaccountlineitem             = lv_glaccountlineitem
                                    glaccount                     = ls_profitcenter-glaccount
                                    documentitemtext              = <ls_item>-customername
                                    profitcenter                  = ls_profitcenter-profitcenter
                                    _currencyamount = VALUE #( ( currencyrole = '00'
                                                                journalentryitemamount = abs( ls_profitcenter-amountintransactioncurrency )
                                                                currency = <ls_item>-transactioncurrency  ) )          ) TO lt_glitem.
                  ENDIF.
                  lv_glaccountlineitem += 1.
                ENDLOOP.
              ELSE.
                APPEND VALUE #( glaccountlineitem             = |001|
                                glaccount                     = <ls_item>-glaccount
                                documentitemtext              = <ls_item>-customername
                                _currencyamount = VALUE #( ( currencyrole = '00'
                                                            journalentryitemamount = -1 * abs( <ls_item>-paymentamount )
                                                            currency = <ls_item>-transactioncurrency  ) )          ) TO lt_glitem.

                APPEND VALUE #( glaccountlineitem             = |002|
                                customer                      = <ls_item>-customer
                                documentitemtext              = 'Havale'
                                _currencyamount = VALUE #( ( currencyrole = '00'
                                                           journalentryitemamount = abs( <ls_item>-paymentamount )
                                                           currency = <ls_item>-transactioncurrency  ) ) ) TO lt_aritem.

                <fs_je>-%param = VALUE #( companycode                  = <ls_item>-companycode
                                          documentreferenceid          = <ls_item>-documentreferenceid
                                          createdbyuser                = sy-uname
                                          businesstransactiontype      = 'RFBU'
                                          accountingdocumenttype       = COND #( WHEN mv_paymentdocumenttype IS INITIAL THEN 'DZ' ELSE mv_paymentdocumenttype )
                                          documentdate                 = cl_abap_context_info=>get_system_date( )
                                          postingdate                  = cl_abap_context_info=>get_system_date( )
                                          accountingdocumentheadertext = |{ <ls_item>-paymentnumber ALPHA = OUT } müşteri ödeme kaydı|
                                          taxdeterminationdate         = cl_abap_context_info=>get_system_date( )
                                          _aritems                     = VALUE #( FOR wa_aritem  IN lt_aritem  ( CORRESPONDING #( wa_aritem  MAPPING _currencyamount = _currencyamount ) ) )
                                          _glitems                     = VALUE #( FOR wa_glitem  IN lt_glitem  ( CORRESPONDING #( wa_glitem  MAPPING _currencyamount = _currencyamount ) ) )
                                        ).
              ENDIF.
              MODIFY ENTITIES OF i_journalentrytp
               ENTITY journalentry
               EXECUTE post FROM lt_je
               FAILED DATA(ls_failed)
               REPORTED DATA(ls_reported)
               MAPPED DATA(ls_mapped).
              IF ls_failed IS NOT INITIAL.
                ms_response-messages = VALUE #( BASE ms_response-messages FOR wa IN ls_reported-journalentry ( message = wa-%msg->if_message~get_text( ) messagetype = mc_error ) ).
              ELSE.
                COMMIT ENTITIES BEGIN
                 RESPONSE OF i_journalentrytp
                 FAILED DATA(ls_commit_failed)
                 REPORTED DATA(ls_commit_reported).
                COMMIT ENTITIES END.
                IF ls_commit_failed IS INITIAL.
                  <ls_item>-paymentdocument = VALUE #( ls_commit_reported-journalentry[ 1 ]-accountingdocument OPTIONAL ).
                  <ls_item>-paymentdocumentyear = VALUE #( ls_commit_reported-journalentry[ 1 ]-fiscalyear OPTIONAL ).
                  create_clearing_document(
                    EXPORTING
                      is_item               = <ls_item>
                    IMPORTING
                      ev_accountingdocument = <ls_item>-clearingdocument
                      ev_fiscalyear         = <ls_item>-clearingdocumentyear
                  ).
                  IF <ls_item>-paymentdocument IS NOT INITIAL.
                    MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 010 WITH <ls_item>-paymentdocument
                                                                        <ls_item>-paymentdocumentyear
                                                                        INTO lv_message.
                    APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
                    CLEAR lv_message.
                  ENDIF.
                  IF <ls_item>-clearingdocument IS NOT INITIAL.
                    MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 010 WITH <ls_item>-clearingdocument
                                                                        <ls_item>-clearingdocumentyear
                                                                        INTO lv_message.
                    APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
                    CLEAR lv_message.
                  ENDIF.
                  UPDATE ypym_t_pay_cus
                    SET paymentdocument = @<ls_item>-paymentdocument,
                        paymentdocumentyear = @<ls_item>-paymentdocumentyear,
                        clearingdocument = @<ls_item>-clearingdocument,
                        clearingdocumentyear = @<ls_item>-clearingdocumentyear
                  WHERE paymentnumber = @<ls_item>-paymentnumber
                    AND accountingdocument = @<ls_item>-accountingdocument
                    AND fiscalyear = @<ls_item>-fiscalyear
                    AND accountingdocumentitem = @<ls_item>-accountingdocumentitem.
                ELSE.
                  ms_response-messages = VALUE #( BASE ms_response-messages FOR wa_commit IN ls_commit_reported-journalentry ( message = wa_commit-%msg->if_message~get_text( ) messagetype = mc_error ) ).
                ENDIF.
              ENDIF.
              CLEAR : lt_je, lt_glitem , lt_aritem ,  ls_failed , ls_reported , ls_commit_failed , ls_commit_reported.
            CATCH cx_uuid_error INTO DATA(lx_error).
              APPEND VALUE #( message = lx_error->get_longtext(  ) messagetype = mc_error ) TO ms_response-messages.
          ENDTRY.
        ELSEIF <ls_item>-clearingdocument IS INITIAL.
          create_clearing_document(
            EXPORTING
              is_item               = <ls_item>
            IMPORTING
              ev_accountingdocument = <ls_item>-clearingdocument
              ev_fiscalyear         = <ls_item>-clearingdocumentyear
          ).
          IF <ls_item>-clearingdocument IS INITIAL.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 012 INTO lv_message.
            APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
          ELSE.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 010 WITH <ls_item>-clearingdocument
                                                                <ls_item>-clearingdocumentyear
                                                                INTO lv_message.
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
            CLEAR lv_message.
          ENDIF.
          UPDATE ypym_t_pay_cus
            SET clearingdocument = @<ls_item>-clearingdocument,
                clearingdocumentyear = @<ls_item>-clearingdocumentyear
          WHERE paymentnumber = @<ls_item>-paymentnumber
            AND accountingdocument = @<ls_item>-accountingdocument
            AND fiscalyear = @<ls_item>-fiscalyear
            AND accountingdocumentitem = @<ls_item>-accountingdocumentitem.
        ELSE.
          MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 013 INTO lv_message.
          APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
        ENDIF.
      ENDLOOP.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).

  ENDMETHOD.
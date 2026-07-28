  METHOD if_http_service_extension~handle_request.
    DATA lt_approve TYPE TABLE OF ypym_t_approve.
    DATA lt_payment TYPE TABLE OF ypym_t_downpay.
    DATA(lv_request_body) = request->get_text( ).
    DATA(lv_get_method) = request->get_method( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).

    lt_payment = CORRESPONDING #(  ms_request-paymentlist ).
    DATA(lt_approvers) = ycl_pym_approvement=>get_all_approvers( EXPORTING
                                                              iv_companycode   = ms_request-companycode
                                                              iv_approvergroup = ms_request-approvergroup ).
    IF lt_approvers IS INITIAL.
      MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 006 INTO DATA(lv_message).
      ms_response-messages = VALUE #( (  messagetype = 'E' message = lv_message ) ).
    ELSE.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = 'YPAYNUMBER'
            IMPORTING
              number            = DATA(lv_paymentnumber)
              returncode        = DATA(lv_returncode)
              returned_quantity = DATA(lv_returned_quantity)
          ).
          IF ms_request-manuelrecord = abap_true.
            DATA(lt_without_iban) = lt_payment.
            DELETE lt_without_iban WHERE supplieriban IS NOT INITIAL.
            SORT lt_without_iban BY supplier.
            DELETE ADJACENT DUPLICATES FROM lt_without_iban COMPARING supplier.
            LOOP AT lt_without_iban ASSIGNING FIELD-SYMBOL(<ls_without_iban>).
              <ls_without_iban>-supplier = |{ <ls_without_iban>-supplier ALPHA = IN }|.
            ENDLOOP.
            IF lt_without_iban IS NOT INITIAL.
              SELECT supplier~supplier,
                     bpbank~bankcountrykey AS supplierbankcountrykey,
                     bpbank~banknumber     AS supplierbanknumber,
                     bpbank~bankaccount    AS supplierbankaccount,
                     bpbank~iban           AS supplieriban,
                     bpbank~swiftcode      AS supplierswiftcode,
                     bpbank~bankname       AS supplierbankname,
                     bank~bankbranch       AS supplierbankbranch
              FROM @lt_without_iban AS supplier
              INNER JOIN i_businesspartnerbank AS bpbank ON bpbank~businesspartner = supplier~supplier
              INNER JOIN i_bank_2 AS bank ON bank~bankcountry = bpbank~bankcountrykey
                                              AND bank~bankinternalid = bpbank~banknumber
              ORDER BY supplier~supplier
              INTO TABLE @DATA(lt_supplier_bank).
            ENDIF.
            DATA(lt_paymentbank) = lt_payment.
            SORT lt_paymentbank BY companybankcode companyaccountcode.
            DELETE ADJACENT DUPLICATES FROM lt_paymentbank COMPARING companybankcode companyaccountcode.
            IF lt_paymentbank IS NOT INITIAL.
              SELECT companybank~*
              FROM @lt_paymentbank AS payment INNER JOIN yi_pym_ddl_company_bankaccount AS companybank
              ON companybank~bankshortid = payment~companybankcode
              AND companybank~accountshortid = payment~companyaccountcode
              ORDER BY companybank~bankshortid , companybank~accountshortid
              INTO TABLE @DATA(lt_companybankinfo).
            ENDIF.
          ENDIF.
          LOOP AT lt_payment ASSIGNING FIELD-SYMBOL(<ls_payment>).
            <ls_payment>-supplier           = |{ <ls_payment>-supplier ALPHA = IN }|.
            <ls_payment>-paymentrequestdate = ms_request-paymentrequestdate.
            <ls_payment>-companycode        = ms_request-companycode.
            <ls_payment>-paymentnumber      = lv_paymentnumber.
            <ls_payment>-approvementstatus  = mc_inprocess.
            <ls_payment>-bankfilestatus     = mc_not_processed.
            <ls_payment>-createduser        = cl_abap_context_info=>get_user_technical_name(  ).
            <ls_payment>-createdate         = cl_abap_context_info=>get_system_date(  ).
            <ls_payment>-createtime         = cl_abap_context_info=>get_system_time(  ).
            <ls_payment>-manuelrecord       = ms_request-manuelrecord.
            IF ms_request-manuelrecord = abap_true.
              IF <ls_payment>-supplieriban IS INITIAL.
                <ls_payment>-supplieriban = VALUE #(  lt_supplier_bank[ supplier = <ls_payment>-supplier ]-supplieriban OPTIONAL ).
              ENDIF.
              READ TABLE lt_companybankinfo INTO DATA(ls_companybankinfo) WITH KEY bankshortid = <ls_payment>-companybankcode
                                                                                   accountshortid = <ls_payment>-companyaccountcode
                                                                                   BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_payment>-companyiban           = ls_companybankinfo-iban.
                <ls_payment>-companybankinternalid = ls_companybankinfo-bankinternalid.
                <ls_payment>-companybankaccount    = ls_companybankinfo-bankaccount.
                <ls_payment>-glaccount             = ls_companybankinfo-glaccount.
              ENDIF.
            ENDIF.
          ENDLOOP.
          INSERT ypym_t_downpay FROM TABLE @lt_payment.
          IF sy-subrc = 0.
            lt_approve = VALUE #( FOR ls_approver IN lt_approvers ( paymentnumber = lv_paymentnumber
                                                                    approvergroupsequence = ls_approver-approvergroupsequence
                                                                    approver = ls_approver-approver
                                                                    paymenttype = ms_request-paymenttype
                                                                    approvementstatus = COND #( WHEN ls_approver-approvergroupsequence = '01' THEN mc_inprocess ELSE mc_waiting ) ) ) .
            INSERT ypym_t_approve FROM TABLE @lt_approve.
            ycl_pym_approvement=>send_mail(
              iv_sender    = ycl_pym_approvement=>get_email( CONV #( cl_abap_context_info=>get_user_technical_name(  ) ) )
              it_recipient = VALUE #( FOR ls_recipient IN lt_approvers WHERE ( approvergroupsequence = '01' ) ( CORRESPONDING #( ls_recipient ) ) )
              iv_subject   = |{ lv_paymentnumber ALPHA = OUT } nolu ödeme onayınızı bekliyor|
              iv_content   = |{ lv_paymentnumber ALPHA = OUT } nolu ödeme onayınızı bekliyor|
            ).
            ms_response-paymentnumber = lv_paymentnumber.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'I' NUMBER 002 WITH |{ lv_paymentnumber ALPHA = OUT }| INTO lv_message.
            ms_response-messages = VALUE #( (  messagetype = 'S' message = lv_message ) ).
          ENDIF.
        CATCH cx_nr_object_not_found.
        CATCH cx_number_ranges.
      ENDTRY.
    ENDIF.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).
  ENDMETHOD.
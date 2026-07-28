  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).

    IF ms_request-supplier IS NOT INITIAL.
      SELECT payment~* FROM @ms_request-supplier AS supplier
               INNER JOIN ypym_t_payment AS payment ON payment~paymentnumber = supplier~paymentnumber
                                                   AND payment~accountingdocument = supplier~accountingdocument
                                                   AND payment~fiscalyear = supplier~fiscalyear
                                                   AND payment~accountingdocumentitem = supplier~accountingdocumentitem
      ORDER BY payment~paymentnumber,payment~accountingdocument,payment~fiscalyear,payment~accountingdocumentitem
      INTO TABLE @DATA(lt_supplier_db).
      LOOP AT lt_supplier_db INTO DATA(ls_supplier_db) WHERE paymentstatus <> '01'.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 019 INTO DATA(lv_message).
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ELSE.
        LOOP AT ms_request-supplier INTO DATA(ls_supplier).
          UPDATE ypym_t_payment
             SET paymentdocument        = @ls_supplier-paymentdocument,
                 paymentdocumentyear    = @ls_supplier-paymentdocumentyear,
                 clearingdocument       = @ls_supplier-clearingdocument,
                 clearingdocumentyear   = @ls_supplier-clearingdocumentyear
           WHERE paymentnumber          = @ls_supplier-paymentnumber
             AND accountingdocument     = @ls_supplier-accountingdocument
             AND fiscalyear             = @ls_supplier-fiscalyear
             AND accountingdocumentitem = @ls_supplier-accountingdocumentitem.
          IF sy-subrc = 0.
            CLEAR lv_message.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 020 WITH ls_supplier-paymentnumber
                                                                ls_supplier-accountingdocument INTO lv_message.
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSEIF ms_request-customer IS NOT INITIAL.
      SELECT payment~* FROM @ms_request-customer AS customer
               INNER JOIN ypym_t_pay_cus AS payment ON payment~paymentnumber = customer~paymentnumber
                                                   AND payment~accountingdocument = customer~accountingdocument
                                                   AND payment~fiscalyear = customer~fiscalyear
                                                   AND payment~accountingdocumentitem = customer~accountingdocumentitem
      ORDER BY payment~paymentnumber,payment~accountingdocument,payment~fiscalyear,payment~accountingdocumentitem
      INTO TABLE @DATA(lt_customer_db).
      LOOP AT lt_customer_db INTO DATA(ls_customer_db) WHERE paymentstatus <> '01'.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 019 INTO lv_message.
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ELSE.
        LOOP AT ms_request-customer INTO DATA(ls_customer).
          UPDATE ypym_t_pay_cus
             SET paymentdocument        = @ls_customer-paymentdocument,
                 paymentdocumentyear    = @ls_customer-paymentdocumentyear,
                 clearingdocument       = @ls_customer-clearingdocument,
                 clearingdocumentyear   = @ls_customer-clearingdocumentyear
           WHERE paymentnumber          = @ls_customer-paymentnumber
             AND accountingdocument     = @ls_customer-accountingdocument
             AND fiscalyear             = @ls_customer-fiscalyear
             AND accountingdocumentitem = @ls_customer-accountingdocumentitem.
          IF sy-subrc = 0.
            CLEAR lv_message.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 020 WITH ls_customer-paymentnumber
                                                                ls_customer-accountingdocument INTO lv_message.
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ELSEIF ms_request-downpay IS NOT INITIAL.
      SELECT downpay_db~* FROM @ms_request-downpay AS downpay
               INNER JOIN ypym_t_downpay AS downpay_db ON downpay_db~paymentnumber = downpay~paymentnumber
                                                      AND downpay_db~purchaseorder = downpay~purchaseorder
                                                      AND downpay_db~purchaseorderitem = downpay~purchaseorderitem
       ORDER BY downpay_db~paymentnumber ,downpay_db~purchaseorder,downpay_db~purchaseorderitem
       INTO TABLE @DATA(lt_downpay_db).
      LOOP AT lt_downpay_db INTO DATA(ls_downpay_db) WHERE paymentstatus <> '01'.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 019 INTO lv_message.
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ELSE.
        LOOP AT ms_request-downpay INTO DATA(ls_downpay).
          UPDATE ypym_t_downpay
             SET paymentdocument        = @ls_downpay-paymentdocument,
                 paymentdocumentyear    = @ls_downpay-paymentdocumentyear
           WHERE paymentnumber          = @ls_downpay-paymentnumber
             AND purchaseorder          = @ls_downpay-purchaseorder
             AND purchaseorderitem      = @ls_downpay-purchaseorderitem.
          IF sy-subrc = 0.
            CLEAR lv_message.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 020 WITH ls_downpay-paymentnumber
                                                                ls_downpay-purchaseorder INTO lv_message.
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).

  ENDMETHOD.
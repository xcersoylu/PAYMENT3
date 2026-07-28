  METHOD if_http_service_extension~handle_request.
    DATA(lv_request_body) = request->get_text( ).
    /ui2/cl_json=>deserialize( EXPORTING json = lv_request_body CHANGING data = ms_request ).
    IF ms_request-supplier IS NOT INITIAL.
      SELECT payment~paymentnumber,
             payment~accountingdocument,
             payment~fiscalyear,
             payment~accountingdocumentitem
        FROM @ms_request-supplier AS supplier INNER JOIN ypym_t_payment AS payment ON payment~paymentnumber = supplier~paymentnumber
                                                                                  AND payment~accountingdocument = supplier~accountingdocument
                                                                                  AND payment~fiscalyear = supplier~fiscalyear
                                                                                  AND payment~accountingdocumentitem = supplier~accountingdocumentitem
       WHERE payment~paymentdocument IS NOT INITIAL
       INTO TABLE @DATA(lt_supplier_check).
      IF lt_supplier_check IS INITIAL.
        LOOP AT ms_request-supplier ASSIGNING FIELD-SYMBOL(<ls_supplier>).
          DELETE FROM ypym_t_payment WHERE paymentnumber = @<ls_supplier>-paymentnumber
                                       AND accountingdocument = @<ls_supplier>-accountingdocument
                                       AND fiscalyear = @<ls_supplier>-fiscalyear
                                       AND accountingdocumentitem = @<ls_supplier>-accountingdocumentitem.
          IF sy-subrc = 0.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 017 WITH <ls_supplier>-paymentnumber
                                                                <ls_supplier>-accountingdocument
                                                                <ls_supplier>-accountingdocumentitem
                                                                INTO DATA(lv_message).
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 018 INTO lv_message.
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ENDIF.
    ELSEIF ms_request-customer IS NOT INITIAL.
      SELECT payment~paymentnumber,
             payment~accountingdocument,
             payment~fiscalyear,
             payment~accountingdocumentitem
        FROM @ms_request-customer AS customer INNER JOIN ypym_t_payment AS payment ON payment~paymentnumber = customer~paymentnumber
                                                                                  AND payment~accountingdocument = customer~accountingdocument
                                                                                  AND payment~fiscalyear = customer~fiscalyear
                                                                                  AND payment~accountingdocumentitem = customer~accountingdocumentitem
       WHERE payment~paymentdocument IS NOT INITIAL
       INTO TABLE @DATA(lt_customer_check).
      IF lt_customer_check IS INITIAL.
        LOOP AT ms_request-customer ASSIGNING FIELD-SYMBOL(<ls_customer>).
          DELETE FROM ypym_t_pay_cus WHERE paymentnumber = @<ls_customer>-paymentnumber
                                       AND accountingdocument = @<ls_customer>-accountingdocument
                                       AND fiscalyear = @<ls_customer>-fiscalyear
                                       AND accountingdocumentitem = @<ls_customer>-accountingdocumentitem.
          IF sy-subrc = 0.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 017 WITH <ls_customer>-paymentnumber
                                                                <ls_customer>-accountingdocument
                                                                <ls_customer>-accountingdocumentitem
                                                                INTO lv_message.
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 018 INTO lv_message.
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ENDIF.
    ELSEIF ms_request-downpay IS NOT INITIAL.
      SELECT downpay_db~paymentnumber,
             downpay_db~purchaseorder,
             downpay_db~purchaseorderitem
        FROM @ms_request-downpay AS downpay INNER JOIN ypym_t_downpay AS downpay_db ON downpay_db~paymentnumber = downpay~paymentnumber
                                                                                   AND downpay_db~purchaseorder = downpay~purchaseorder
                                                                                   AND downpay_db~purchaseorderitem = downpay~purchaseorderitem
         WHERE downpay_db~paymentdocument IS NOT INITIAL
         INTO TABLE @DATA(lt_downpay_check).
      IF lt_downpay_check IS INITIAL.
        LOOP AT ms_request-downpay ASSIGNING FIELD-SYMBOL(<ls_downpay>).
          DELETE FROM ypym_t_downpay WHERE paymentnumber = @<ls_downpay>-paymentnumber
                                       AND purchaseorder = @<ls_downpay>-purchaseorder
                                       AND purchaseorderitem = @<ls_downpay>-purchaseorderitem.
          IF sy-subrc = 0.
            MESSAGE ID 'YPYM_MESSAGES' TYPE 'S' NUMBER 017 WITH <ls_downpay>-paymentnumber
                                                                <ls_downpay>-purchaseorder
                                                                <ls_downpay>-purchaseorderitem
                                                                INTO lv_message.
            APPEND VALUE #( messagetype = 'S' message = lv_message ) TO ms_response-messages.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE ID 'YPYM_MESSAGES' TYPE 'E' NUMBER 018 INTO lv_message.
        APPEND VALUE #( messagetype = 'E' message = lv_message ) TO ms_response-messages.
      ENDIF.
    ENDIF.
    DATA(lv_response_body) = /ui2/cl_json=>serialize( EXPORTING data = ms_response ).
    response->set_text( lv_response_body ).
    response->set_header_field( i_name = mc_header_content i_value = mc_content_type ).

  ENDMETHOD.
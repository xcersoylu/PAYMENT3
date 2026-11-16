  METHOD get_email_data.
    CASE mv_paymenttype.
      WHEN '01'.
*        SELECT payment~*,i_supplier~suppliername FROM @mt_supplier_deleted AS supplier INNER JOIN ypym_t_payment AS payment ON payment~paymentnumber = supplier~paymentnumber
        SELECT payment~*,i_supplier~suppliername FROM @ms_request-supplier AS supplier INNER JOIN ypym_t_payment AS payment ON payment~paymentnumber = supplier~paymentnumber
                                                                                  AND payment~accountingdocument = supplier~accountingdocument
                                                                                  AND payment~fiscalyear = supplier~fiscalyear
                                                                                  AND payment~accountingdocumentitem = supplier~accountingdocumentitem
                                                               INNER JOIN i_supplier ON i_supplier~supplier = payment~supplier
         ORDER BY payment~paymentnumber,payment~accountingdocument,payment~fiscalyear,payment~accountingdocumentitem
         INTO CORRESPONDING FIELDS OF TABLE @mt_supplier_email_data.
      WHEN '03'.
*        SELECT payment~*,i_customer~customername FROM @mt_customer_deleted AS customer INNER JOIN ypym_t_pay_cus AS payment ON payment~paymentnumber = customer~paymentnumber
        SELECT payment~*,i_customer~customername FROM @ms_request-customer AS customer INNER JOIN ypym_t_pay_cus AS payment ON payment~paymentnumber = customer~paymentnumber
                                                                                  AND payment~accountingdocument = customer~accountingdocument
                                                                                  AND payment~fiscalyear = customer~fiscalyear
                                                                                  AND payment~accountingdocumentitem = customer~accountingdocumentitem
                                                               INNER JOIN i_customer ON i_customer~customer = payment~customer
         ORDER BY payment~paymentnumber,payment~accountingdocument,payment~fiscalyear,payment~accountingdocumentitem
         INTO CORRESPONDING FIELDS OF TABLE @mt_customer_email_data.
      WHEN '02'.
*        SELECT downpay_db~*,i_supplier~suppliername FROM @mt_downpay_deleted AS downpay INNER JOIN ypym_t_downpay AS downpay_db ON downpay_db~paymentnumber = downpay~paymentnumber
        SELECT downpay_db~*,i_supplier~suppliername FROM @ms_request-downpay AS downpay INNER JOIN ypym_t_downpay AS downpay_db ON downpay_db~paymentnumber = downpay~paymentnumber
                                                                                    AND downpay_db~purchaseorder = downpay~purchaseorder
                                                                                    AND downpay_db~purchaseorderitem = downpay~purchaseorderitem
                                                                INNER JOIN i_supplier ON i_supplier~supplier = downpay_db~supplier
        ORDER BY downpay_db~paymentnumber , downpay_db~purchaseorder,downpay_db~purchaseorderitem
        INTO CORRESPONDING FIELDS OF TABLE @mt_downpay_email_data.
    ENDCASE.
  ENDMETHOD.
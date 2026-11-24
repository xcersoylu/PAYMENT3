  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE TABLE OF ypym_t_parameter.
    APPEND VALUE #( parametername = 'SUPPLIER' parameterkey = 'PAYMENT_DOCUMENT_TYPE' ) TO lt_parameters.
    APPEND VALUE #( parametername = 'SUPPLIER' parameterkey = 'CLEARING_DOCUMENT_TYPE' ) TO lt_parameters.
    APPEND VALUE #( parametername = 'CUSTOMER' parameterkey = 'PAYMENT_DOCUMENT_TYPE' ) TO lt_parameters.
    APPEND VALUE #( parametername = 'CUSTOMER' parameterkey = 'CLEARING_DOCUMENT_TYPE' ) TO lt_parameters.
    APPEND VALUE #( parametername = 'DOWNPAY' parameterkey = 'PAYMENT_DOCUMENT_TYPE' ) TO lt_parameters.
    APPEND VALUE #( parametername = 'DELETED_LINES' parameterkey = 'SEND_EMAIL' ) TO lt_parameters.
    APPEND VALUE #( parametername = 'ACCOUNTING_DOCUMENT' parameterkey = 'PROFIT_CENTER' ) TO lt_parameters.
    MODIFY ypym_t_parameter FROM TABLE @lt_parameters.
  ENDMETHOD.
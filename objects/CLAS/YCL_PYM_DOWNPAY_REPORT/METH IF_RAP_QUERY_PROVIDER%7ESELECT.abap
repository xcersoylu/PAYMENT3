  METHOD if_rap_query_provider~select.
    DATA lt_data TYPE TABLE OF yi_pym_ddl_downpay_report.
    DATA lt_paged TYPE TABLE OF yi_pym_ddl_downpay_report.
    DATA lt_paymentnumber       TYPE RANGE OF ypym_e_paymentnumber.
    DATA lt_supplier            TYPE RANGE OF lifnr.
    DATA lt_companycode         TYPE RANGE OF bukrs.
    DATA lt_approvementstatus   TYPE RANGE OF ypym_e_approvementstatus.
    DATA lt_paymentstatus       TYPE RANGE OF ypym_e_paymentstatus.
    DATA lt_bankfilestatus      TYPE RANGE OF ypym_e_bankfilestatus.
    DATA lt_glaccount           TYPE RANGE OF hkont.
    TRY.
        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'PAYMENTNUMBER'.
              lt_paymentnumber = CORRESPONDING #( ls_filter-range ).
            WHEN 'SUPPLIER'.
              lt_supplier = CORRESPONDING #( ls_filter-range ).
            WHEN 'COMPANYCODE'.
              lt_companycode = CORRESPONDING #( ls_filter-range ).
            WHEN 'APPROVEMENTSTATUS'.
              lt_approvementstatus = CORRESPONDING #( ls_filter-range ).
            WHEN 'PAYMENTSTATUS'.
              lt_paymentstatus = CORRESPONDING #( ls_filter-range ).
            WHEN 'BANKFILESTATUS'.
              lt_bankfilestatus = CORRESPONDING #( ls_filter-range ).
            WHEN 'GLACCOUNT'.
              lt_glaccount = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.
      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
    SELECT paymentnumber,
           purchaseorder,
           purchaseorderitem,
           supplier,
           companycode,
           paymentamount,
           currency,
           supplieriban,
           companybankcode,
           companyiban,
           glaccount,
           paymentrequestdate,
           approvementstatus,
           app_text~text AS approvementstatus_tx,
           bankfilestatus,
           bnk_text~text AS bankfilestatus_tx,
           paymentstatus,
           pay_text~text AS paymentstatus_tx,
           paymentdocument,
           paymentdocumentyear
    FROM ypym_t_downpay AS downpay
    LEFT OUTER JOIN ddcds_customer_domain_value_t( p_domain_name = 'YPYM_D_PAYMENTSTATUS' ) AS pay_text
    ON pay_text~value_low = downpay~paymentstatus
    AND pay_text~language = @sy-langu
    LEFT OUTER JOIN ddcds_customer_domain_value_t( p_domain_name = 'YPYM_D_APPROVEMENTSTATUS' ) AS app_text
    ON app_text~value_low = downpay~approvementstatus
    AND app_text~language = @sy-langu
    LEFT OUTER JOIN ddcds_customer_domain_value_t( p_domain_name = 'YPYM_D_BANKFILESTATUS' ) AS bnk_text
    ON bnk_text~value_low = downpay~bankfilestatus
    AND bnk_text~language = @sy-langu
    WHERE downpay~paymentnumber      IN @lt_paymentnumber
      AND downpay~supplier           IN @lt_supplier
      AND downpay~companycode        IN @lt_companycode
      AND downpay~approvementstatus  IN @lt_approvementstatus
      AND downpay~bankfilestatus     IN @lt_bankfilestatus
      AND downpay~paymentstatus      IN @lt_paymentstatus
      AND downpay~glaccount          IN @lt_glaccount
    INTO CORRESPONDING FIELDS OF TABLE @lt_data.
    IF sy-subrc = 0.
      DATA(lo_paging) = io_request->get_paging( ).
      DATA(lv_top)  = lo_paging->get_page_size( ).
      DATA(lv_skip) = lo_paging->get_offset( ).
      lt_paged = lt_data.
      IF lv_skip > 0.
        DELETE lt_paged FROM 1 TO lv_skip.
      ENDIF.
      IF lv_top > 0 AND lv_top < lines( lt_paged ).
        DELETE lt_paged FROM lv_top + 1 TO lines( lt_paged ).
      ENDIF.
      io_response->set_data( it_data = lt_paged ).
      IF io_request->is_total_numb_of_rec_requested(  ).
        io_response->set_total_number_of_records( lines( lt_paged ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
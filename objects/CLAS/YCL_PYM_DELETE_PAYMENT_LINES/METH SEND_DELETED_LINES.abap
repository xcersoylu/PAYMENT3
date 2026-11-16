  METHOD send_deleted_lines.
    DATA(lt_approvers) = get_approvers( ).
    IF lt_approvers IS NOT INITIAL.
*      get_email_data(  ).
      LOOP AT lt_approvers INTO DATA(ls_approver) GROUP BY ( approver = ls_approver-approver ).
        CLEAR : mt_supplier_mail_lines , mt_customer_mail_lines , mt_downpay_mail_lines.
        LOOP AT GROUP ls_approver INTO DATA(ls_member).
          CASE mv_paymenttype.
            WHEN '01'.
              DATA(lt_supplier_lines) = mt_supplier_deleted.
              DELETE lt_supplier_lines WHERE paymentnumber <> ls_member-paymentnumber.
              APPEND LINES OF lt_supplier_lines TO mt_supplier_mail_lines.
            WHEN '03'.
              DATA(lt_customer_lines) = mt_customer_deleted.
              DELETE lt_customer_lines WHERE paymentnumber <> ls_member-paymentnumber.
              APPEND LINES OF lt_customer_lines TO mt_customer_mail_lines.              .
            WHEN '02'.
              DATA(lt_downpay_lines) = mt_downpay_deleted.
              DELETE lt_downpay_lines WHERE paymentnumber <> ls_member-paymentnumber.
              APPEND LINES OF lt_downpay_lines TO mt_downpay_mail_lines.
          ENDCASE.
        ENDLOOP.
        DATA(lv_content) = prepare_mail_content(  ).
        ycl_pym_approvement=>send_mail(
          iv_sender    = ycl_pym_approvement=>get_email( CONV #( cl_abap_context_info=>get_user_technical_name(  ) ) )
          it_recipient =  VALUE #( ( email = ls_approver-email ) )
          iv_subject   = |Silinen ödeme listesi kalemleri|
          iv_content   = lv_content
        ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
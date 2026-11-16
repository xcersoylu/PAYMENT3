  METHOD get_approvers.
    CASE mv_paymenttype.
      WHEN '01'.
        SELECT approve~paymentnumber,
               approve~approver,
               i_businessuservh~defaultemailaddress AS email
               FROM @mt_supplier_deleted AS supplier INNER JOIN ypym_t_approve AS approve ON approve~paymentnumber = supplier~paymentnumber
                                                                                         AND approve~approvementstatus = 'APPROVED'
                                                                                         AND approve~paymenttype = @mv_paymenttype
                                                     LEFT OUTER JOIN i_businessuservh ON i_businessuservh~userid =  approve~approver
        ORDER BY approve~paymentnumber, approve~approver
        INTO CORRESPONDING FIELDS OF TABLE @rt_approvers.
        IF sy-subrc = 0.
          DELETE ADJACENT DUPLICATES FROM rt_approvers COMPARING paymentnumber approver.
        ENDIF.
      WHEN '03'.
        SELECT approve~paymentnumber,
               approve~approver,
               i_businessuservh~defaultemailaddress AS email
               FROM @mt_customer_deleted AS customer INNER JOIN ypym_t_approve AS approve ON approve~paymentnumber = customer~paymentnumber
                                                                                         AND approve~approvementstatus = 'APPROVED'
                                                                                         AND approve~paymenttype = @mv_paymenttype
                                                     LEFT OUTER JOIN i_businessuservh ON i_businessuservh~userid =  approve~approver
        ORDER BY approve~paymentnumber, approve~approver
        INTO CORRESPONDING FIELDS OF TABLE @rt_approvers.
        IF sy-subrc = 0.
          DELETE ADJACENT DUPLICATES FROM rt_approvers COMPARING paymentnumber approver.
        ENDIF.
      WHEN '02'.
        SELECT approve~paymentnumber,
               approve~approver,
               i_businessuservh~defaultemailaddress AS email
               FROM @mt_downpay_deleted AS downpay INNER JOIN ypym_t_approve AS approve ON approve~paymentnumber = downpay~paymentnumber
                                                                                         AND approve~approvementstatus = 'APPROVED'
                                                                                         AND approve~paymenttype = @mv_paymenttype
                                                   LEFT OUTER JOIN i_businessuservh ON i_businessuservh~userid =  approve~approver
        ORDER BY approve~paymentnumber, approve~approver
        INTO CORRESPONDING FIELDS OF TABLE @rt_approvers.
        IF sy-subrc = 0.
          DELETE ADJACENT DUPLICATES FROM rt_approvers COMPARING paymentnumber approver.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
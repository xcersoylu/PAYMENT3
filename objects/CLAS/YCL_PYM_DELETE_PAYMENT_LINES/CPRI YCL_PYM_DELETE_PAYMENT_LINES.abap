  PRIVATE SECTION.
    TYPES : BEGIN OF ty_approver,
              paymentnumber TYPE ypym_e_paymentnumber,
              approver      TYPE syuname,
              email         TYPE ypym_e_email,
            END OF ty_approver,
            tt_approver TYPE TABLE OF ty_approver WITH EMPTY KEY,
            BEGIN OF ty_supplier_email,
              paymentnumber          TYPE ypym_e_paymentnumber,
              accountingdocument     TYPE belnr_d,
              fiscalyear             TYPE gjahr,
              accountingdocumentitem TYPE buzei,
              supplier               TYPE lifnr,
              suppliername           TYPE ypym_e_suppliername,
              paymentamount          TYPE ypym_e_paymentamount,
              currency               TYPE waers,
            END OF ty_supplier_email,
            tt_supplier_email TYPE TABLE OF ty_supplier_email WITH EMPTY KEY,
            BEGIN OF ty_customer_email,
              paymentnumber          TYPE ypym_e_paymentnumber,
              accountingdocument     TYPE belnr_d,
              fiscalyear             TYPE gjahr,
              accountingdocumentitem TYPE buzei,
              customer               TYPE kunnr,
              customername           TYPE ypym_e_customername,
              paymentamount          TYPE ypym_e_paymentamount,
              currency               TYPE waers,
            END OF ty_customer_email,
            tt_customer_email TYPE TABLE OF ty_customer_email WITH EMPTY KEY,
            BEGIN OF ty_downpay_email,
              paymentnumber     TYPE ypym_e_paymentnumber,
              purchaseorder     TYPE ebeln,
              purchaseorderitem TYPE ebelp,
              supplier          TYPE lifnr,
              suppliername      TYPE ypym_e_suppliername,
              paymentamount     TYPE ypym_e_paymentamount,
              currency          TYPE waers,
            END OF ty_downpay_email,
            tt_downpay_email TYPE TABLE OF ty_downpay_email WITH EMPTY KEY.
    DATA: ms_request  TYPE ypym_s_del_payment_lines_req,
          ms_response TYPE ypym_s_del_payment_lines_res.
    DATA mt_supplier_deleted TYPE ypym_tt_delete_supplier_lines.
    DATA mt_customer_deleted TYPE ypym_tt_delete_customer_lines.
    DATA mt_downpay_deleted  TYPE ypym_tt_delete_downpay_lines.
    DATA mt_supplier_mail_lines TYPE ypym_tt_delete_supplier_lines.
    DATA mt_customer_mail_lines TYPE ypym_tt_delete_customer_lines.
    DATA mt_downpay_mail_lines  TYPE ypym_tt_delete_downpay_lines.
    DATA mt_supplier_email_data TYPE tt_supplier_email.
    DATA mt_customer_email_data TYPE tt_customer_email.
    DATA mt_downpay_email_data TYPE tt_downpay_email.
    DATA mv_paymenttype TYPE ypym_e_paymenttype.
    METHODS send_deleted_lines.
    METHODS get_approvers RETURNING VALUE(rt_approvers) TYPE tt_approver.
    METHODS prepare_mail_content
      RETURNING
        VALUE(rv_content) TYPE string.
    METHODS get_email_data.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json'.
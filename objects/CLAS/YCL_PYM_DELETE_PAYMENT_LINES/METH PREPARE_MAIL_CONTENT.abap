  METHOD prepare_mail_content.
    CASE mv_paymenttype.
      WHEN '01'.
        DATA(lv_html) = |<html><body>|.
        lv_html &&= |<p>Merhaba,</p>|.
        lv_html &&= |<p>Aşağıdaki satırlar ödeme listesinden silinmiştir.</p>|.
        lv_html &&= |<table border="1" cellpadding="6" cellspacing="0" | &&
                    |style="border-collapse:collapse;width:100%;font-family:Arial;font-size:13px;">|.
        lv_html &&= |<tr style="background-color:#D9EAF7;">|.
        lv_html &&= |<th>Ödeme Numarası</th>|.
        lv_html &&= |<th>Muhasebe Belgesi</th>|.
        lv_html &&= |<th>Mali Yıl</th>|.
        lv_html &&= |<th>Belge Kalemi</th>|.
        lv_html &&= |<th>Satıcı</th>|.
        lv_html &&= |<th>Satıcı Adı</th>|.
        lv_html &&= |<th>Ödenecek Tutar</th>|.
        lv_html &&= |<th>Para Birimi</th>|.
        lv_html &&= |</tr>|.
        LOOP AT mt_supplier_mail_lines INTO DATA(ls_supplier_mail_line).
          READ TABLE mt_supplier_email_data INTO DATA(ls_supplier_email_data) WITH KEY paymentnumber = ls_supplier_mail_line-paymentnumber
                                                                                       accountingdocument = ls_supplier_mail_line-accountingdocument
                                                                                       fiscalyear = ls_supplier_mail_line-fiscalyear
                                                                                       accountingdocumentitem = ls_supplier_mail_line-accountingdocumentitem
                                                                                       BINARY SEARCH.
          lv_html &&= |<tr>|.
          lv_html &&= |<td>{ ls_supplier_mail_line-paymentnumber ALPHA = OUT }</td>|.
          lv_html &&= |<td>{ ls_supplier_mail_line-accountingdocument }</td>|.
          lv_html &&= |<td>{ ls_supplier_mail_line-fiscalyear }</td>|.
          lv_html &&= |<td>{ ls_supplier_mail_line-accountingdocumentitem }</td>|.
          lv_html &&= |<td>{ ls_supplier_email_data-supplier }</td>|.
          lv_html &&= |<td>{ ls_supplier_email_data-suppliername }</td>|.
          lv_html &&= |<td>{ ls_supplier_email_data-paymentamount }</td>|.
          lv_html &&= |<td>{ ls_supplier_email_data-currency }</td>|.
          lv_html &&= |</tr>|.
        ENDLOOP.
        lv_html &&= |</table>|.
        lv_html &&= |</body></html>|.
      WHEN '03'.
        lv_html = |<html><body>|.
        lv_html &&= |<p>Merhaba,</p>|.
        lv_html &&= |<p>Aşağıdaki satırlar ödeme listesinden silinmiştir.</p>|.
        lv_html &&= |<table border="1" cellpadding="6" cellspacing="0" | &&
                    |style="border-collapse:collapse;width:100%;font-family:Arial;font-size:13px;">|.
        lv_html &&= |<tr style="background-color:#D9EAF7;">|.
        lv_html &&= |<th>Ödeme Numarası</th>|.
        lv_html &&= |<th>Muhasebe Belgesi</th>|.
        lv_html &&= |<th>Mali Yıl</th>|.
        lv_html &&= |<th>Belge Kalemi</th>|.
        lv_html &&= |<th>Müşteri</th>|.
        lv_html &&= |<th>Müşteri Adı</th>|.
        lv_html &&= |<th>Ödenecek Tutar</th>|.
        lv_html &&= |<th>Para Birimi</th>|.
        lv_html &&= |</tr>|.
        LOOP AT mt_customer_mail_lines INTO DATA(ls_customer_mail_line).
          READ TABLE mt_customer_email_data INTO DATA(ls_customer_email_data) WITH KEY paymentnumber = ls_customer_mail_line-paymentnumber
                                                                                       accountingdocument = ls_customer_mail_line-accountingdocument
                                                                                       fiscalyear = ls_customer_mail_line-fiscalyear
                                                                                       accountingdocumentitem = ls_customer_mail_line-accountingdocumentitem
                                                                                       BINARY SEARCH.
          lv_html &&= |<tr>|.
          lv_html &&= |<td>{ ls_customer_mail_line-paymentnumber ALPHA = OUT }</td>|.
          lv_html &&= |<td>{ ls_customer_mail_line-accountingdocument }</td>|.
          lv_html &&= |<td>{ ls_customer_mail_line-fiscalyear }</td>|.
          lv_html &&= |<td>{ ls_customer_mail_line-accountingdocumentitem }</td>|.
          lv_html &&= |<td>{ ls_customer_email_data-customer }</td>|.
          lv_html &&= |<td>{ ls_customer_email_data-customername }</td>|.
          lv_html &&= |<td>{ ls_customer_email_data-paymentamount }</td>|.
          lv_html &&= |<td>{ ls_customer_email_data-currency }</td>|.
          lv_html &&= |</tr>|.
        ENDLOOP.
        lv_html &&= |</table>|.
        lv_html &&= |</body></html>|.
      WHEN '02'.
        lv_html = |<html><body>|.
        lv_html &&= |<p>Merhaba,</p>|.
        lv_html &&= |<p>Aşağıdaki satırlar ödeme listesinden silinmiştir.</p>|.
        lv_html &&= |<table border="1" cellpadding="6" cellspacing="0" | &&
                    |style="border-collapse:collapse;width:100%;font-family:Arial;font-size:13px;">|.
        lv_html &&= |<tr style="background-color:#D9EAF7;">|.
        lv_html &&= |<th>Ödeme Numarası</th>|.
        lv_html &&= |<th>Satınalma Belgesi</th>|.
        lv_html &&= |<th>Belge Kalemi</th>|.
        lv_html &&= |<th>Satıcı</th>|.
        lv_html &&= |<th>Satıcı Adı</th>|.
        lv_html &&= |<th>Ödenecek Tutar</th>|.
        lv_html &&= |<th>Para Birimi</th>|.
        lv_html &&= |</tr>|.
        LOOP AT mt_downpay_mail_lines INTO DATA(ls_downpay_mail_line).
          READ TABLE mt_downpay_email_data INTO DATA(ls_downpay_email_data) WITH KEY paymentnumber = ls_downpay_mail_line-paymentnumber
                                                                                     purchaseorder = ls_downpay_mail_line-purchaseorder
                                                                                     purchaseorderitem = ls_downpay_mail_line-purchaseorderitem
                                                                                     BINARY SEARCH.
          lv_html &&= |<tr>|.
          lv_html &&= |<td>{ ls_downpay_mail_line-paymentnumber ALPHA = OUT }</td>|.
          lv_html &&= |<td>{ ls_downpay_mail_line-purchaseorder }</td>|.
          lv_html &&= |<td>{ ls_downpay_mail_line-purchaseorderitem }</td>|.
          lv_html &&= |<td>{ ls_downpay_email_data-supplier }</td>|.
          lv_html &&= |<td>{ ls_downpay_email_data-suppliername }</td>|.
          lv_html &&= |<td>{ ls_downpay_email_data-paymentamount }</td>|.
          lv_html &&= |<td>{ ls_downpay_email_data-currency }</td>|.
          lv_html &&= |</tr>|.
        ENDLOOP.
        lv_html &&= |</table>|.
        lv_html &&= |</body></html>|.
    ENDCASE.

    rv_content = lv_html.
  ENDMETHOD.
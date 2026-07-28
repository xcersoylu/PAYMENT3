managed implementation in class zbp_i_pym_ddl_payment_update unique;
strict ( 2 );

define behavior for YI_PYM_DDL_PAYMENT_UPDATE //alias <alias_name>
persistent table ypym_t_payment
lock master
authorization master ( instance )
//etag master <field_name>
{
  create ( authorization : global );
  update;
  delete;
  field ( readonly ) Paymentnumber, Accountingdocument, Fiscalyear, Accountingdocumentitem;
  mapping for ypym_t_payment
    {
      Paymentnumber          = paymentnumber;
      Accountingdocument     = accountingdocument;
      Fiscalyear             = fiscalyear;
      Accountingdocumentitem = accountingdocumentitem;
      Approvementstatus      = approvementstatus;
      Bankfilestatus         = bankfilestatus;
      Paymentstatus          = paymentstatus;
      Paymentdocument        = paymentdocument;
      Paymentdocumentyear    = paymentdocumentyear;
      Clearingdocument       = clearingdocument;
      Clearingdocumentyear   = clearingdocumentyear;
    }
}
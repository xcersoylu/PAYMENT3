managed implementation in class zbp_i_pym_ddl_pay_cus_update unique;
strict ( 2 );

define behavior for YI_PYM_DDL_PAY_CUS_UPDATE //alias <alias_name>
persistent table ypym_t_pay_cus
lock master
authorization master ( instance )
//etag master <field_name>
{
  create ( authorization : global );
  update;
  delete;
  field ( readonly ) Paymentnumber, Accountingdocument, Fiscalyear, Accountingdocumentitem;
  mapping for ypym_t_pay_cus
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
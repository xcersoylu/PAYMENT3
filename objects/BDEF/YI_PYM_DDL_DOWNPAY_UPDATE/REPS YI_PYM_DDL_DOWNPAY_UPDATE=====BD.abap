managed implementation in class zbp_i_pym_ddl_downpay_update unique;
strict ( 2 );

define behavior for YI_PYM_DDL_DOWNPAY_UPDATE //alias <alias_name>
persistent table ypym_t_downpay
lock master
authorization master ( instance )
//etag master <field_name>
{
  create ( authorization : global );
  update;
  delete;
  field ( readonly ) Paymentnumber, Purchaseorder, Purchaseorderitem;
  mapping for ypym_t_downpay
    {
      Paymentnumber       = paymentnumber;
      Purchaseorder       = purchaseorder;
      Purchaseorderitem   = purchaseorderitem;
      Approvementstatus   = approvementstatus;
      Bankfilestatus      = bankfilestatus;
      Paymentstatus       = paymentstatus;
      Paymentdocument     = paymentdocument;
      Paymentdocumentyear = paymentdocumentyear;
    }
}
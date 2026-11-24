  PRIVATE SECTION.
    TYPES : BEGIN OF ty_profitcenter,
              companycode                 TYPE i_journalentryitem-companycode,
              accountingdocument          TYPE i_journalentryitem-accountingdocument,
              accountingdocumentitem      TYPE i_journalentryitem-accountingdocumentitem,
              ledgergllineitem            TYPE i_journalentryitem-ledgergllineitem,
              fiscalyear                  TYPE i_journalentryitem-fiscalyear,
              customer                    TYPE i_journalentryitem-customer,
              profitcenter                TYPE i_journalentryitem-profitcenter,
              amountintransactioncurrency TYPE i_journalentryitem-amountintransactioncurrency,
            END OF ty_profitcenter,
            tt_profitcenter TYPE TABLE OF ty_profitcenter WITH EMPTY KEY.
    CONSTANTS mc_error          TYPE messagetyp VALUE 'E'.
    DATA: ms_request        TYPE ypym_s_create_fin_doc_cus_req,
          ms_response       TYPE ypym_s_create_fin_doc_cus_res,
          mc_header_content TYPE string VALUE 'content-type',
          mc_content_type   TYPE string VALUE 'text/json',
          mv_profit_center  TYPE ypym_t_parameter-value,
          mt_profitcenter   TYPE tt_profitcenter,
          mv_clearingdocumenttype TYPE blart,
          mv_paymentdocumenttype  TYPE blart.
    METHODS create_clearing_document IMPORTING is_item               TYPE ypym_s_save_doc_cus_item
                                     EXPORTING ev_accountingdocument TYPE belnr_d
                                               ev_fiscalyear         TYPE gjahr.
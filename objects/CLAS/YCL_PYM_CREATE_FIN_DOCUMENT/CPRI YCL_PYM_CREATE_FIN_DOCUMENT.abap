  PRIVATE SECTION.
    TYPES : BEGIN OF ty_profitcenter,
              companycode                 TYPE i_journalentryitem-companycode,
              accountingdocument          TYPE i_journalentryitem-accountingdocument,
              accountingdocumentitem      TYPE i_journalentryitem-accountingdocumentitem,
              ledgergllineitem            TYPE i_journalentryitem-ledgergllineitem,
              fiscalyear                  TYPE i_journalentryitem-fiscalyear,
              supplier                    TYPE i_journalentryitem-supplier,
              profitcenter                TYPE i_journalentryitem-profitcenter,
              amountintransactioncurrency TYPE i_journalentryitem-amountintransactioncurrency,
            END OF ty_profitcenter,
            tt_profitcenter TYPE TABLE OF ty_profitcenter WITH EMPTY KEY.
    CONSTANTS mc_error          TYPE messagetyp VALUE 'E'.
    DATA: ms_request              TYPE ypym_s_create_fin_document_req,
          ms_response             TYPE ypym_s_create_fin_document_res,
          mc_header_content       TYPE string VALUE 'content-type',
          mc_content_type         TYPE string VALUE 'text/json',
          mv_profit_center        TYPE ypym_t_parameter-value,
          mt_profitcenter         TYPE tt_profitcenter,
          mv_clearingdocumenttype TYPE blart,
          mv_paymentdocumenttype  TYPE blart.
*          mt_clearing_document TYPE tt_clearing_document.
    METHODS create_clearing_document IMPORTING is_item               TYPE ypym_s_payment_save_doc_item
                                     EXPORTING ev_accountingdocument TYPE belnr_d
                                               ev_fiscalyear         TYPE gjahr.
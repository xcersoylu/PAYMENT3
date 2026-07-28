  PRIVATE SECTION.
    DATA: ms_request  TYPE ypym_s_del_payment_lines_req,
          ms_response TYPE ypym_s_del_payment_lines_res.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json'.
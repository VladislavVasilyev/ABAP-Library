method parser__for.

  constants
  : cs_packagesize   type string value `PACKAGE\sSIZE`
  , cs_for_not_found type string value `FOR\sNOT\sFOUND`
  .

  e_v__tablename = gr_o__cursor->get_token( esc = abap_true ).

  read table i_t__container
       with key tablename = e_v__tablename
       transporting no fields.

  if sy-subrc ne 0.
    raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_table_not_defined
                      token  = e_v__tablename
                      index  = gr_o__cursor->gd_v__index .
  endif.

  if gr_o__cursor->check_tokens( q = 2 regex = cs_packagesize ) = abap_true.
    gr_o__cursor->get_token( esc = abap_true trn = 2 ).
    e_v__packagesize = gr_o__cursor->get_token( esc = abap_true ).
  else.
    e_v__packagesize = -1.
  endif.

  if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
    raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_expected
                    token  = zblnc_keyword-dot
                    index  = gr_o__cursor->gd_v__index .
  endif.

endmethod.

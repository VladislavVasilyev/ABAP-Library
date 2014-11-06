method parser__for.

*  data lr_o__for type ref to zcl_bdnl_parser_for .

  constants
  : cs_packagesize   type string value `PACKAGE\sSIZE`
*  , cs_for_not_found type string value `FOR\sNOT\sFOUND`
  , cs_with_key      type string value `^\$WITH\sKEY$`
  .

  e_v__tablename = gr_o__cursor->get_token( esc = abap_true ).
  e_f__with_key = abap_false.

  zcl_bdnl_container=>check_table( e_v__tablename ).

*  read table i_t__container
*       with key tablename = e_v__tablename
*       transporting no fields.
*
*  if sy-subrc ne 0.
*    raise exception type zcx_bdnl_syntax_error
*            exporting textid = zcx_bdnl_syntax_error=>zcx_table_not_defined
*                      token  = e_v__tablename
*                      index  = gr_o__cursor->gd_v__index .
*  endif.

  if gr_o__cursor->check_tokens( q = 2 regex = cs_packagesize ) = abap_true.
    gr_o__cursor->get_token( esc = abap_true trn = 2 ).
    e_v__packagesize = gr_o__cursor->get_token( esc = abap_true ).
  else.
    e_v__packagesize = -1.
  endif.

  if gr_o__cursor->get_token( ) eq zblnc_keyword-dot.
    gr_o__cursor->get_token( esc = abap_true ).
  elseif gr_o__cursor->check_tokens( q = 2 regex = cs_with_key ) = abap_true.
    gr_o__cursor->get_token( esc = abap_true trn = 2 ).
    e_f__with_key = abap_true.
  else.
    raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_expected
                    expected  = '"."  or  "$WITH KEY"'
                    index  = gr_o__cursor->gd_v__index .
  endif.

endmethod.

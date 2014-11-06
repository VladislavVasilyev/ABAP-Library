method read_statements.

  constants
  : cs_with_key type string value `^\$WITH\sKEY$`
  .

  clear e_s__stack.

  e_s__stack-tablename  = gr_o__cursor->get_token( esc = abap_true ).

  zcl_bdnl_container=>check_table( e_s__stack-tablename ).

  if gr_o__cursor->check_tokens( q = 2 regex = cs_with_key ) = abap_true.
    gr_o__cursor->get_token( esc = abap_true trn = 2 ).

    call method read_with_key
      exporting
        i_v__tablename = e_s__stack-tablename
      importing
        e_t__custlink  = e_s__stack-link.

  elseif gr_o__cursor->get_tokens( q = 1 ) = zblnc_keyword-from.
    gr_o__cursor->get_token( esc = abap_true trn = 1 ).
    call method read_from
      importing
        default = e_s__stack-default.

  endif.

  if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
    raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                    token  = gr_o__cursor->gd_v__ctoken
                    index  = gr_o__cursor->gd_v__cindex .
  endif.

endmethod.

method clear_statements.

  constants
  : cs__regex type string value `^([A-Z0-9\_]+)\>\~\<([A-Z0-9\_]+)\>`
  .

  data
  : ld_v__index         type i
  , ld_v__token         type string
  , ld_v__str           type string
  .

  clear e_s__stack.

  call method cmd_from " FROM
    importing
      e_appset_id = e_s__stack-appset_id
      e_appl_id   = e_s__stack-appl_id
      e_appl_obj  = e_s__stack-appl_obj.

  if gr_o__cursor->get_token( ) = zblnc_keyword-where. " WHERE
    gr_o__cursor->get_token( esc = abap_true ).
    call method select_param_where
      exporting
        i_appset_id = e_s__stack-appset_id
        i_appl_id   = e_s__stack-appl_id
        i_appl_obj  = e_s__stack-appl_obj
      importing
        e_t__range  = e_s__stack-range.
  endif.

  if gr_o__cursor->get_token( ) ne zblnc_keyword-dot.
    raise exception type zcx_bdnl_syntax_error
          exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                    expected = zblnc_keyword-dot
                    index    = gr_o__cursor->gd_v__index .
  endif.

  gr_o__cursor->get_token( esc = abap_true ).

  add 1 to cd_v__cnt_clear.

  ld_v__str = cd_v__cnt_clear.
  condense ld_v__str no-gaps.

  concatenate `CLEAR: -` ld_v__str `-` into: e_s__stack-tablename, e_v__tablename.

  e_o__container = zcl_bdnl_container=>get_table( e_s__stack ).

endmethod.

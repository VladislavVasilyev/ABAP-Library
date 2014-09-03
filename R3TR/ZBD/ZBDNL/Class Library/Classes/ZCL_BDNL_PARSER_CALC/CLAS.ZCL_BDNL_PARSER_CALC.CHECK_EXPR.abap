method check_expr.

  data
  : ld_v__token       type string
  , ld_s__check       type zbnlt_s__stack_check
  , ld_s__last_op     type zbnlt_s__stack_check
  , ld_v__index       type i
  .

  field-symbols
  : <ld_s__check>     type zbnlt_s__stack_check
  .

  do.
    ld_s__check = check_term( abap_true ).

    ld_v__index = lines( gd_t__check ).
    read table gd_t__check index ld_v__index
         into ld_s__last_op.

    if ld_s__check-log_exp is initial.

      case  ld_s__check-token.
        when `AND` or `OR`.
          if not ( ld_s__last_op-log_exp is not initial or ld_s__last_op-token = `)` ).
            raise exception type zcx_bdnl_syntax_error
                  exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                      token    = ld_v__token
                            index    = gr_o__cursor->gd_v__index.
          endif.

          append ld_s__check to gd_t__check.
          continue.
        when `NOT`.
          append ld_s__check to gd_t__check.
          continue.

        when `)`.
          if get = abap_false.
            raise exception type zcx_bdnl_syntax_error
                  exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                      token    = ld_v__token
                            index    = gr_o__cursor->gd_v__index.
          endif.
          append ld_s__check to gd_t__check.
          return = ld_s__check.
          exit.

        when zblnc_keyword-dot.
          if not ( ld_s__last_op-log_exp is not initial or ld_s__last_op-token = `)` ).
            raise exception type zcx_bdnl_syntax_error
                   exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                      token    = ld_v__token
                             index    = gr_o__cursor->gd_v__index.
          endif.

          return = ld_s__check.
          exit.
        when others.
          return = ld_s__check.
          exit.
      endcase.
    else.
      append ld_s__check to gd_t__check.
      continue.
    endif.
  enddo.

  if get = abap_false.
    loop at gd_t__check assigning <ld_s__check>.
      <ld_s__check>-turn = i_v__turn.
    endloop.
  endif.

endmethod.

method check_term.

  data
  : ld_s__check       type zbnlt_s__stack_check
  , ld_v__log_exp     type c length 2
  , ld_s__last_op     type zbnlt_s__stack_check
  , ld_v__index       type i
  .

  ld_s__check         = check_prim( get ).

  ld_v__index = lines( gd_t__check ).
  read table gd_t__check index ld_v__index
       into ld_s__last_op.


  if ld_s__check-left is not initial.
    if not ( ld_s__last_op-token = `OR`  or ld_s__last_op-token = `AND`
    or ld_s__last_op-token = `NOT` or ld_s__last_op-token = `(` or ld_v__index = 0 ).
      raise exception type zcx_bdnl_syntax_error
            exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                      token    = ld_v__token
                      index    = gr_o__cursor->gd_v__index.
    endif.

    return-left         = ld_s__check-left.
    ld_v__log_exp       = gr_o__cursor->get_token( esc = abap_true ).

    case  ld_v__log_exp.
      when `=`  or `EQ`.
        return-log_exp = `EQ`.
      when `<>` or `NE`.
        return-log_exp = `NE`.
      when `>`  or `GT`.
        return-log_exp = `GT`.
      when `<`  or `LT`.
        return-log_exp = `LT`.
      when `>=` or `GE`.
        return-log_exp = `GE`.
      when `<=` or `LE`.
        return-log_exp = `LE`.
      when `IS`.
        if gr_o__cursor->get_token( ) = `NOT`.
          gr_o__cursor->get_token( esc = abap_true ).
          if gr_o__cursor->get_token( ) = `INITIAL`.
            gr_o__cursor->get_token( esc = abap_true ).
            return-log_exp = `NI`.
          else.
            raise exception type zcx_bdnl_syntax_error
            exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                      expected = `INITIAL`
                      index     = gr_o__cursor->gd_v__index.
          endif.
        elseif gr_o__cursor->get_token( ) = `INITIAL`.
          gr_o__cursor->get_token( esc = abap_true ).
          return-log_exp = `II`.
        else.
          raise exception type zcx_bdnl_syntax_error
           exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                     expected = `INITIAL`
                     index     = gr_o__cursor->gd_v__index.
        endif.
        return.
      when others.
        raise exception type zcx_bdnl_syntax_error
              exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                        expected = `LOG EXP`
                        index     = gr_o__cursor->gd_v__index.
    endcase.

    ld_s__check         = check_prim( get ).

    if ld_s__check-left is not initial.
      return-right       = ld_s__check-left.
    else.
      raise exception type zcx_bdnl_syntax_error
      exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                      token    = ld_v__token
                index    = gr_o__cursor->gd_v__index.
    endif.
  elseif ld_s__check-token is not initial.
    return-token = ld_s__check-token.
  endif.

endmethod.

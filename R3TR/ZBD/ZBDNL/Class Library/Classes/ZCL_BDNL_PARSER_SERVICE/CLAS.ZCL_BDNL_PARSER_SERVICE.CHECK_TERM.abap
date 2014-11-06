method check_term.

  data
  : ld_s__check               type zbnlt_s__stack_check
  , ld_v__log_exp             type c length 2
  , ld_s__last_op             type zbnlt_s__stack_check
  , ld_v__index               type i
  .

  ld_s__check         = check_prim( get ).

  ld_v__index = lines( gd_t__check ).
  read table gd_t__check index ld_v__index
       into ld_s__last_op.


  if ld_s__check-left is not initial.
    if not (
               ld_s__last_op-token = zblnc_keyword-or
            or ld_s__last_op-token = zblnc_keyword-and
            or ld_s__last_op-token = zblnc_keyword-not
            or ld_s__last_op-token = zblnc_keyword-open_parenthesis
            or ld_v__index         = 0
           ).

      raise exception type zcx_bdnl_syntax_error
            exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
                      token    = ld_s__last_op-token
                      index    = gr_o__cursor->gd_v__cindex.
    endif.

    return-left         = ld_s__check-left.
    ld_v__log_exp       = gr_o__cursor->get_token( esc = abap_true ).

    case  ld_v__log_exp.
      when `=`  or zblnc_keyword-eq.
        return-log_exp = zblnc_keyword-eq.
        if gr_o__cursor->get_token( ) = zblnc_keyword-in.
          gr_o__cursor->get_token( esc = abap_true ).
          return-in = abap_true.
        endif.
      when `<>` or zblnc_keyword-ne.
        return-log_exp = zblnc_keyword-ne.
        if gr_o__cursor->get_token( ) = zblnc_keyword-in.
          gr_o__cursor->get_token( esc = abap_true ).
          return-in = abap_true.
        endif.
      when `>`  or zblnc_keyword-gt.
        return-log_exp = zblnc_keyword-gt.
        if gr_o__cursor->get_token( ) = zblnc_keyword-in.
          gr_o__cursor->get_token( esc = abap_true ).
          return-in = abap_true.
        endif.
      when `<`  or zblnc_keyword-lt.
        return-log_exp = zblnc_keyword-lt.
        if gr_o__cursor->get_token( ) = zblnc_keyword-in.
          gr_o__cursor->get_token( esc = abap_true ).
          return-in = abap_true.
        endif.
      when `>=` or zblnc_keyword-ge.
        return-log_exp = zblnc_keyword-ge.
        if gr_o__cursor->get_token( ) = zblnc_keyword-in.
          gr_o__cursor->get_token( esc = abap_true ).
          return-in = abap_true.
        endif.
      when `<=` or zblnc_keyword-le.
        return-log_exp = zblnc_keyword-le.
        if gr_o__cursor->get_token( ) = zblnc_keyword-in.
          gr_o__cursor->get_token( esc = abap_true ).
          return-in = abap_true.
        endif.
      when zblnc_keyword-is.
        if gr_o__cursor->get_token( ) = zblnc_keyword-not.
          gr_o__cursor->get_token( esc = abap_true ).
          if gr_o__cursor->get_token( ) = zblnc_keyword-initial.
            gr_o__cursor->get_token( esc = abap_true ).
            return-log_exp = zblnc_keyword-ni.
          else.
            raise exception type zcx_bdnl_syntax_error
            exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                      expected = zblnc_keyword-initial
                      index     = gr_o__cursor->gd_v__index.
          endif.
        elseif gr_o__cursor->get_token( ) = zblnc_keyword-initial.
          gr_o__cursor->get_token( esc = abap_true ).
          return-log_exp = zblnc_keyword-ii.
        else.
          raise exception type zcx_bdnl_syntax_error
           exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                     expected = zblnc_keyword-initial
                     index    = gr_o__cursor->gd_v__index.
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

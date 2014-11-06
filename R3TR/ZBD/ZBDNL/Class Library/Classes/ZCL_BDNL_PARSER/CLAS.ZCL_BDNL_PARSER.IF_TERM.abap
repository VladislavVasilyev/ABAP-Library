method if_term.

  return = if_prim( ).

  check get = abap_true.

  case if_prim( ).
    when zblnc_keyword-eq.
      if return eq if_prim(  )."if_prim( abap_true ).
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-ne.
      if return ne if_prim(  ).
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-gt.
      if return gt if_prim(  ).
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-lt.
      if return lt if_prim(  ).
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-ge.
      if return ge if_prim(  ).
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-le.
      if return le if_prim(  ).
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-ii.
      if return is initial.
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-ni.
      if return is not initial.
        return = true.
      else.
        return = false.
      endif.
    when zblnc_keyword-open_parenthesis.
      gr_o__cursor->get_token( esc = abap_true ).
      return = if_expr(  ).

      if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-close_parenthesis.
        raise exception type zcx_bdnl_syntax_error
              exporting textid   = zcx_bdnl_syntax_error=>zcx_inc_le_parent
                        token    = `)`
                        token1   = `(`
                        index     = gr_o__cursor->gd_v__cindex.
      endif.
    when zblnc_keyword-not.
      gr_o__cursor->get_token( esc = abap_true ).
      return = if_term( abap_true ).

      if return = true.
        return = false.
      else.
        return = true.
      endif.

    when others.
      return.
  endcase.

endmethod.

method if_prim.

  case gr_o__cursor->get_token( ).
    when zblnc_keyword-not.
      return = zblnc_keyword-not.
    when zblnc_keyword-open_parenthesis.
      return = zblnc_keyword-open_parenthesis.
    when zblnc_keyword-and.
      gr_o__cursor->get_token( esc = abap_true ).
      return = zblnc_keyword-and.
    when zblnc_keyword-or.
      gr_o__cursor->get_token( esc = abap_true ).
      return = zblnc_keyword-or.
    when zblnc_keyword-close_parenthesis.
      return = zblnc_keyword-close_parenthesis.
    when zblnc_keyword-dot.
      return = zblnc_keyword-dot.
    when `=`  or zblnc_keyword-eq.
      gr_o__cursor->get_token( esc = abap_true ).
      return = zblnc_keyword-eq.
    when `<>` or zblnc_keyword-ne.
      return = zblnc_keyword-ne.
    when `>`  or zblnc_keyword-gt.
      return = zblnc_keyword-gt.
    when `<`  or zblnc_keyword-lt.
      return = zblnc_keyword-lt.
    when `>=` or zblnc_keyword-ge.
      return = zblnc_keyword-ge.
    when `<=` or zblnc_keyword-le.
      return = zblnc_keyword-le.
    when zblnc_keyword-is.
      gr_o__cursor->get_token( esc = abap_true ). " IS
      if gr_o__cursor->get_token( ) = zblnc_keyword-initial.
        gr_o__cursor->get_token( esc = abap_true ). " INITIAL
        return = zblnc_keyword-ii.
      elseif gr_o__cursor->get_token( ) = zblnc_keyword-not.
        gr_o__cursor->get_token( esc = abap_true ). " NOT
        if gr_o__cursor->get_token( esc = abap_true ) = zblnc_keyword-initial. "INITIAL
          return = zblnc_keyword-ni.
        else.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = `"INITIAL"`
                          index     = gr_o__cursor->gd_v__cindex .
        endif.
      else.
        gr_o__cursor->get_token( esc = abap_true ).
        raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                        expected  = `"INITIAL" or "NOT INITIAL"`
                        index     = gr_o__cursor->gd_v__cindex .
      endif.
    when others.
      if gr_o__cursor->check_letter( )  = abap_true or
       gr_o__cursor->check_variable( ) = abap_true .
        return = gr_o__cursor->get_token( esc = abap_true ).
      elseif gr_o__cursor->check_num( )  = abap_true .
        return = gr_o__cursor->get_token( esc = abap_true ).
      endif.
  endcase.

endmethod.

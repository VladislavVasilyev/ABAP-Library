method select_where_opt.

  case token.
    when zblnc_keyword-eq or `=`.
      option = zblnc_keyword-eq.
    when zblnc_keyword-ne or `<>`.
      option = zblnc_keyword-ne.
    when zblnc_keyword-lt or `<`.
      option = zblnc_keyword-lt.
    when zblnc_keyword-gt or `>`.
      option = zblnc_keyword-gt.
    when zblnc_keyword-le or `<=`.
      option = zblnc_keyword-le .
    when zblnc_keyword-ge or `>=`.
      option = zblnc_keyword-ge.
    when zblnc_keyword-co.
      option = zblnc_keyword-co.
    when zblnc_keyword-cn.
      option = zblnc_keyword-cn.
    when zblnc_keyword-ca.
      option = zblnc_keyword-ca.
    when zblnc_keyword-na.
      option = zblnc_keyword-na.
    when zblnc_keyword-cs.
      option = zblnc_keyword-cs.
    when zblnc_keyword-ns.
      option = zblnc_keyword-ns.
    when zblnc_keyword-cp.
      option = zblnc_keyword-cp.
    when zblnc_keyword-np.
      option = zblnc_keyword-np.
    when zblnc_keyword-between or zblnc_keyword-bt.
      option = zblnc_keyword-bt.
    when others.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                      token  = token
                      index  = gr_o__cursor->gd_v__index .
  endcase.

endmethod.

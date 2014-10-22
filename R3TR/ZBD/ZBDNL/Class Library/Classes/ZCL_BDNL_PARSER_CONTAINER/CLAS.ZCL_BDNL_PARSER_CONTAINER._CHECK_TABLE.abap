method _CHECK_TABLE.

  read table gd_t__containers
     with key tablename = tablename
     transporting no fields.

  if sy-subrc = 0.
    raise exception type zcx_bdnl_syntax_error
        exporting textid   = zcx_bdnl_syntax_error=>zcx_has_declarate
                  token    = tablename
                  index    = gr_o__cursor->gd_v__cindex.
  endif.

  read table gd_t__stack
     with key tablename = tablename
     transporting no fields.

  if sy-subrc = 0.
    raise exception type zcx_bdnl_syntax_error
        exporting textid   = zcx_bdnl_syntax_error=>zcx_has_declarate
                  token    = tablename
                  index    = gr_o__cursor->gd_v__cindex.
  endif.

endmethod.

method CHECK_TABLE_DECL.

  data
  : ld_s__reestr type ty_s__reestr
  .

  ld_s__reestr-tablename = tablename.
  ld_s__reestr-script    = cd_v__current_script .


  read table cd_t__table_reestr from ld_s__reestr  transporting no fields.

  if sy-subrc = 0.
    raise exception type zcx_bdnl_syntax_error
        exporting textid   = zcx_bdnl_syntax_error=>zcx_has_declarate
                  token    = tablename
                  index    = zcl_bdnl_parser=>cr_o__cursor->gd_v__cindex.
  endif.

endmethod.

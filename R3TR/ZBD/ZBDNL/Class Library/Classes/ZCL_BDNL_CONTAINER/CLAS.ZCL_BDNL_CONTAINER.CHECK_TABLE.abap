method check_table.

  data
  : ld_s__reestr type ty_s__reestr
*  , ld_v__string type string
  .

  field-symbols
  : <ld_s__reestr> type ty_s__reestr
  .

  ld_s__reestr-tablename = tablename.
  ld_s__reestr-script    = cd_v__current_script .


  read table cd_t__table_reestr from ld_s__reestr  assigning <ld_s__reestr>.

  if sy-subrc <> 0.
    raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_table_not_defined
                      token  = tablename
                      index  = zcl_bdnl_parser=>cr_o__cursor->gd_v__cindex .
  else.
    e_s__param = <ld_s__reestr>-container->gd_s__param.
  endif.

endmethod.

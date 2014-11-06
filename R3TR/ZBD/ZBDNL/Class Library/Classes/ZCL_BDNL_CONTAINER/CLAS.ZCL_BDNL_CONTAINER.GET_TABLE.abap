method get_table.

  data
  : ld_s__reestr type ty_s__reestr
  .

  ld_s__reestr-tablename = i_s__param-tablename.
  ld_s__reestr-script    = zcl_bdnl_parser=>cr_o__cursor->gd_v__script_path.

  read table cd_t__table_reestr from ld_s__reestr transporting no fields.

  create object e_o__container
    exporting
      i_param = i_s__param.

  ld_s__reestr-container = e_o__container.

  insert ld_s__reestr into table cd_t__table_reestr.

endmethod.

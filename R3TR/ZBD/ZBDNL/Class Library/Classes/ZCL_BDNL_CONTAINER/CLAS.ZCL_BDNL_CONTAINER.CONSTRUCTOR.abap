method constructor.

  gd_s__param       = i_param.
  gd_v__command     = i_param-command .
  gd_v__type_table  = i_param-type_table.
  GD_V__TABLENAME   = i_param-tablename.
  gd_v__script  = zcl_bdnl_parser=>cr_o__cursor->gd_v__script_path.

endmethod.

method set_appl_table.
  data
  : lr_o__appl_ctrl type ref to zcl_bd00_appl_ctrl
  .

  f_appl_table = abap_true.

  lr_o__appl_ctrl ?= me.

  delete table cd_t__object_reestr with table key object = lr_o__appl_ctrl.

endmethod.

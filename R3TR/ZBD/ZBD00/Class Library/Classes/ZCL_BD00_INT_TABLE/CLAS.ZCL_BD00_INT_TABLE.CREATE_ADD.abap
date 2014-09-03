method CREATE_ADD.
  data
  : lo_class      type ref to zcl_bd00_int_table
  , lv_name_class type string
  .

  if io_line is bound and io_line is supplied.
    lv_name_class = zcl_bd00_int_table_ctrl=>create_dyn_add( io_tg = io_tg io_line = io_line ).

    create object lo_class
      type
        (lv_name_class)
      exporting
        io_tg        = io_tg
        io_line      = io_line.
*    set handler eo_class->class->change_fline for io_line activation 'X'.
  else.
*    create object lo_class type zcl_bd00_int_table_ctrl
*      exporting
*        signature = signature.
  endif.

  eo_class ?= lo_class.

*  set handler eo_class->class->change_table for io_tg activation 'X'.

endmethod.

method get_assign_function.

  data
  : lr_o__me            type ref to zcl_bdnl_parser_service
  , ld_s__custlink      type zbnlt_s__cust_link
  .

  create object lr_o__me
    exporting
      i_r__cursor = i_r__cursor.

  call method lr_o__me->process_function
    importing
      e_v__funcname = ld_s__custlink-func_name
      e_t__param    = ld_s__custlink-param
      e_r__data     = ld_s__custlink-data. " e_r__data.

  call method zcl_bdnl_parser_service=>create_assign_function
    exporting
      i_s__function = ld_s__custlink
    importing
      e_t__function = e_t__function.

  e_r__data = ld_s__custlink-data.

endmethod.

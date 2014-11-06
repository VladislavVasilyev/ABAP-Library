method get_func.

  data
  : lr_o__me type ref to zcl_bdnl_parser_service
  .

  create object lr_o__me
    exporting
      i_r__cursor = i_r__cursor.

  call method lr_o__me->process_function
    importing
      e_v__funcname = e_v__funcname
      e_t__param    = e_t__param
      e_r__data     = e_r__data.

endmethod.

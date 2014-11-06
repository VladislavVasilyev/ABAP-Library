method get_check.

  data
  : lr_o__me type ref to zcl_bdnl_parser_service
  .

  create object lr_o__me
    exporting
      i_r__cursor = i_r__cursor.

  lr_o__me->check_expr( get = abap_false i_v__turn = i_v__turn ).

  e_t__check = lr_o__me->gd_t__check.

endmethod.

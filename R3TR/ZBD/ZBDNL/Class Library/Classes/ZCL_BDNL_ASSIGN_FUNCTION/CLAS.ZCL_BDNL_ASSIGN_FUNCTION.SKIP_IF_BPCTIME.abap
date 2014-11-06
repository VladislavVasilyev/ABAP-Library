method skip_if_bpctime.

  data
  : left_val      type string
  , rigth_val     type string
  , left_val_p    type i
  , rigth_val_p   type i
  , op            type string
*  , val           type string
  .

*  zcl_debug=>stop_program( ).

  e         = i04.
  op        = i02.
  left_val  = i01.
  rigth_val = i03.

  left_val_p = __get_time( left_val ).
  rigth_val_p = __get_time( rigth_val ).

  case op.
    when `=`  or `EQ`.
      check left_val_p eq rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `<>` or `NE`.
      check left_val_p ne rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `<`  or `LT`.
      check left_val_p lt rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `>`  or `GT`.
      check left_val_p gt rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `<=` or `LE`.
      check left_val_p le rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `>=` or `GE`.
      check left_val_p ge rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when others.
      raise exception type zcx_bdnl_skip_assign.
  endcase.


endmethod.

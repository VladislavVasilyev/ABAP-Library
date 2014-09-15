method skip_if.

  data
  : left_val      type string
  , rigth_val     type string
  , left_val_p    type p
  , rigth_val_p   type p
  , op            type string
  , val           type string
  .

*  zcl_debug=>stop_program( ).

  e         = i04.
  op        = i02.
  left_val  = i01.
  rigth_val = i03.

  case op.
    when `=`  or `EQ`.
      check left_val eq rigth_val.
      raise exception type zcx_bdnl_skip_assign.
    when `<>` or `NE`.
      check left_val ne rigth_val.
      raise exception type zcx_bdnl_skip_assign.
    when `<`  or `LT`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      check left_val_p lt rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `>`  or `GT`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      check left_val_p gt rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `<=` or `LE`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      check left_val_p le rigth_val_p.
      raise exception type zcx_bdnl_skip_assign.
    when `>=` or `GE`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      check left_val_p ge rigth_val_P.
      raise exception type zcx_bdnl_skip_assign.
    when others.
      raise exception type zcx_bdnl_skip_assign.
  endcase.


endmethod.

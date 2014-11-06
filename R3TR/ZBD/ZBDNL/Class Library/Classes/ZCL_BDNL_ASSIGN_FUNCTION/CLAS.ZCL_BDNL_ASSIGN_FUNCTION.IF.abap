method if.

  data
  : left_val      type string
  , rigth_val     type string
  , left_val_p    type p
  , rigth_val_p   type p
  , op            type string
*  , val           type string
  .

*  zcl_debug=>stop_program( ).


  op        = i02.
  left_val  = i01.
  rigth_val = i03.

  case op.
    when `=`  or `EQ`.
      if left_val eq rigth_val.
        e         = i04.
      else.
        e         = i05.
      endif.
    when `<>` or `NE`.
      if left_val ne rigth_val.
        e         = i04.
      else.
        e         = i05.
      endif.
    when `<`  or `LT`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      if left_val_p lt rigth_val_p.
        e         = i04.
      else.
        e         = i05.
      endif.
    when `>`  or `GT`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      if left_val_p gt rigth_val_p.
        e         = i04.
      else.
        e         = i05.
      endif.
    when `<=` or `LE`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      if left_val_p le rigth_val_p.
        e         = i04.
      else.
        e         = i05.
      endif.
    when `>=` or `GE`.
      left_val_p  = left_val .
      rigth_val_p = rigth_val.
      if left_val_p ge rigth_val_p.
        e         = i04.
      else.
        e         = i05.
      endif.
    when others.
      e         = i05.
  endcase.

endmethod.

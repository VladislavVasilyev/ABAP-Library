method assign_function.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method assign_function_____________st
        exporting
          i_s__function = i_s__function
          i_v__turn     = i_v__turn
          i_s__for      = i_s__for
        importing
          e_t__function = e_t__function.
    when `NEW`.
      call method assign_function_____________nv
       exporting
          i_s__function = i_s__function
          i_v__turn     = i_v__turn
          i_s__for      = i_s__for
        importing
          e_t__function = e_t__function.
  endcase.

endmethod.

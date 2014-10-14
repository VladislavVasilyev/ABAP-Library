method create_assign_rule.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method create_assign_rule__________st
        exporting
          i_s__for              = i_s__for
          i_v__turn             = i_v__turn
        importing
          e_t__assign           = e_t__assign
          e_t__assign_not_found = e_t__assign_not_found.
    when `NEW`.
      call method create_assign_rule__________nv
        exporting
          i_s__for              = i_s__for
          i_v__turn             = i_v__turn
        importing
          e_t__assign           = e_t__assign
          e_t__assign_not_found = e_t__assign_not_found.
  endcase.

endmethod.

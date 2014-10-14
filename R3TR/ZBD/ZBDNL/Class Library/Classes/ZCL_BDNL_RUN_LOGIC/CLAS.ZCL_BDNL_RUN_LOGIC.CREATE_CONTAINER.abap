method create_container.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method create_container____________st
        exporting
          i_s__for       = i_s__for
          i_v__tablename = i_v__tablename
        receiving
          e_s__table     = e_s__table.
    when `NEW`.
      call method create_container____________st
        exporting
          i_s__for       = i_s__for
          i_v__tablename = i_v__tablename
        receiving
          e_s__table     = e_s__table.
  endcase.

endmethod.

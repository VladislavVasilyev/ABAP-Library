method work_circle.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method work_circle_________________st
        exporting
          i_s__for = i_s__for.
    when `NEW`.
      call method work_circle_________________nv
        exporting
          i_s__for = i_s__for.
  endcase.

endmethod.

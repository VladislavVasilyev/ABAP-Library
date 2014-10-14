method clear_containers.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method clear_containers____________st.
    when `NEW`.
      call method clear_containers____________nv.
  endcase.

endmethod.

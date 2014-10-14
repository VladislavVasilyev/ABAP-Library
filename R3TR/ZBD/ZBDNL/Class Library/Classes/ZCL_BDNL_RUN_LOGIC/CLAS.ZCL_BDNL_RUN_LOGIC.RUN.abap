method run.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method run_________________________st.
    when `NEW`.
      call method run_________________________nv.
  endcase.

endmethod.

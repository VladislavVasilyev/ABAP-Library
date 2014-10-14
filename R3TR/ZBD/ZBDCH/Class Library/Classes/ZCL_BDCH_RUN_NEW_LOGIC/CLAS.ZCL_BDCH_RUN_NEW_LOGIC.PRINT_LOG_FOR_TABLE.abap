method print_log_for_table.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method print_log_for_table_________st
        exporting
          i_t__containers = i_t__containers
          i_v__path       = i_v__path
        receiving
          e_f__warning    = e_f__warning.
    when `NEW`.
      call method print_log_for_table_________nv
        exporting
          i_t__containers = i_t__containers
          i_v__path       = i_v__path
        receiving
          e_f__warning    = e_f__warning.
  endcase.

endmethod.

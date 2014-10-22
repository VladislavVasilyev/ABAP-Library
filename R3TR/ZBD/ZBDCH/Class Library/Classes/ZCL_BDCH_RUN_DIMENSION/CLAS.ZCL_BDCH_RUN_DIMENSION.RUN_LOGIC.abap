method run_logic.


  case gd_v__mode.
    when cs_save.
      call method download
        importing
          ef_success = ef_success
          ef_warning = ef_warning.
    when cs_process.
      upload( ).
    when others.
  endcase.


endmethod.

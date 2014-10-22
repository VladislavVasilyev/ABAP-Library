method actual_ctables.

  field-symbols
  : <ld_s__log> type ty_s__log
  .

  loop at cd_t__log assigning <ld_s__log>
       where n_script = cd_v__n_script
         and n_turn   = cd_v__n_turn
         and n_for    = cd_v__n_for
         and command  = zblnc_keyword-ctable.

    <ld_s__log>-n_actual = <ld_s__log>-table->set_actual_rows( ).

  endloop.

endmethod.

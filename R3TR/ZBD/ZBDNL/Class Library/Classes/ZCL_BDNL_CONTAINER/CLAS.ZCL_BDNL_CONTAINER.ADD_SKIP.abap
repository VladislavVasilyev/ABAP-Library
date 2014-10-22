method ADD_SKIP.

  field-symbols
  : <ld_s__log> type ty_s__log
  .

  assign cr_s__log->* to <ld_s__log>.

  check sy-subrc = 0.
  add 1 to <ld_s__log>-skip_rows.

endmethod.

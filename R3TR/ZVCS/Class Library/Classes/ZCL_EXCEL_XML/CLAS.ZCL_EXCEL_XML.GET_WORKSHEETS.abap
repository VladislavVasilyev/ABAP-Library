method get_worksheets.

  field-symbols
  : <ld_s__worksheet> type ty_s__worksheet
  .

  loop at gd_t__worksheet assigning <ld_s__worksheet>.
    append <ld_s__worksheet>-name to worksheets.
  endloop.
endmethod.

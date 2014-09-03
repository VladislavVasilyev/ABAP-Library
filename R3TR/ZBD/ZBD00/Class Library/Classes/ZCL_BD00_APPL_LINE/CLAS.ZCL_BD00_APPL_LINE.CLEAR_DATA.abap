method clear_data.
  field-symbols
  : <cline> type any
  .

  assign cline->* to <cline>.

  clear
  : line
  , <cline>
  .

  raise event ev_change_line.
endmethod.

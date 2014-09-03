method CLEAR.

  field-symbols
  : <table>  type any table
  , <cline>  type any
  .

  if gr_o__line is bound.
      gr_o__line->clear_data( ).
  endif.

*aa

  if gr_o__table is bound.
    assign gr_o__table->gr_t__table->* to <table>.
    clear
    : <table>
    .
  endif.

*as

 raise event ev_change_line.
endmethod.

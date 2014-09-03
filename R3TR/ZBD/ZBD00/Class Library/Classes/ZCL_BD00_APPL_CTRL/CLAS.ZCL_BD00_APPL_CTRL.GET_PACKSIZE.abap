method get_packsize.

  field-symbols
  : <lt_data> type any table
  .

  assign gr_o__table->gr_t__table->* to <lt_data>.

  e = lines( <lt_data> ).
endmethod.

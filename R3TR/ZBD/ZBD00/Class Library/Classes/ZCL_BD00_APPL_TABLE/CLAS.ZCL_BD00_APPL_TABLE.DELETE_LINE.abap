method DELETE_LINE.

  field-symbols
  : <index_table>  type index table
  .

  assign gr_t__table->* to <index_table>.

  check gr_o__line->gd_v__index > 0.

  delete <index_table> index gr_o__line->gd_v__index.

  if sy-subrc = 0.
    raise event ev_delete_line.
    clear gr_o__line->gd_v__index.
  endif.

endmethod.

method change_table.
  data
  : lr_result type ref to data
  .

  field-symbols
  : <hashed_table> type hashed table
  .

  go_rline->clear_data( ).

  if gd_v__table_kind = cl_abap_tabledescr=>tablekind_hashed.
    assign gref_table->* to <hashed_table>.

    loop at <hashed_table> reference into lr_result.
      append lr_result to gt_result.
    endloop.
  endif.

endmethod.

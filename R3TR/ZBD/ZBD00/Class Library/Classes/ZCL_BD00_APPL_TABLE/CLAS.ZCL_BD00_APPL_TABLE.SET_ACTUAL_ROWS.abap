method set_actual_rows.

  data
  : ld_s__actual type zbd0t_s__log_actual
  , ld_v__size   type i
  .

  field-symbols
  : <lt_data> type any table
  .

  assign gr_o__table->gr_t__table->* to <lt_data>.

  ld_v__size = lines( <lt_data> ).

  e = gr_o__table->gr_o__process_data->go_log->set_actual( ld_v__size ).

endmethod.

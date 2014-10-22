method get_log.

  e_t__read           = gr_o__table->gr_o__process_data->go_log->gd_t__read.
  e_t__write          = gr_o__table->gr_o__process_data->go_log->gd_t__write.
  e_t__read_dim       = gr_o__table->gr_o__process_data->go_log->gd_t__read_dim.
  e_t__actual_rows    = gr_o__table->gr_o__process_data->go_log->gd_t__num_rows.

  sort
  : e_t__read   by nr_pack ascending
  , e_t__write  by nr_pack ascending
  .

endmethod.

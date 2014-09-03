method WRITE_BACK.

  gr_o__process_data->write_data_arfc( ).

  check IF_CLEAR = abap_true.
  me->clear( ).

endmethod.

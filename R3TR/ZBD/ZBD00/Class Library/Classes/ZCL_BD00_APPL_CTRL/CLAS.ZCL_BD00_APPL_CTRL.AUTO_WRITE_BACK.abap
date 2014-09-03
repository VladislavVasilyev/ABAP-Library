method auto_write_back.

  check
  : gd_f__auto_save = abap_true
  , lines >= gr_o__model->gr_o__application->gd_v__package_size.
  .


  field-symbols: <d> type any table.

  gr_o__table->write_back( ).

  gr_o__table->clear( ).
endmethod.

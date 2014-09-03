method constructor.

  gr_o__params = i_o__param.

  create object gr_o__rfc_task
    exporting
      num           = i_v__num_tasks
      parallel_task = i_f__parallel_task.

  if i_f__parallel_task = abap_true.
    message s053(zbdnl) with `ON` i_v__num_tasks.
  else.
    message s053(zbdnl) with `OFF` i_v__num_tasks.
  endif.

  gd_f__rspc = i_f__rspc.

endmethod.

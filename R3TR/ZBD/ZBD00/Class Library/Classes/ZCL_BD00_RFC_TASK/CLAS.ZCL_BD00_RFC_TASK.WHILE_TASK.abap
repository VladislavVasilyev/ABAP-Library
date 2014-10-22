method while_task.

  data
  : gd_v__while_end type tzntstmpl
  , delta           type tzntstmpl
  , free_pbt_wps    type i
  .

  check_wait_free_tasks( ).

  get time stamp field gd_v__while_end.

  delta = cl_abap_tstmp=>subtract( tstmp1 = gd_v__while_end
                                   tstmp2 = cd_v__while_start ).

  exit = abap_true.

  if delta > 1800.
    raise exception type zcx_bd00_rfc_task.
  endif.

endmethod.

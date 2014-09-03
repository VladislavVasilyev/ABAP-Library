method SET_TASK_FREE.

  field-symbols
     : <ls_rfc_process> like line of dt_rfc_process
     , <ls_appl_write>  like line of dt_appl_write
     .

  read table dt_rfc_process
        with key  task = task
        assigning <ls_rfc_process>.

  <ls_rfc_process>-st = cs-rfc_free.

  read table dt_appl_write
       with key task = task
       assigning <ls_appl_write>.

  if sy-subrc = 0.
    clear <ls_appl_write>-task.
  endif.

  add       1 to   nr_free_tasks.
  subtract  1 from nr_use_tasks.

  case <ls_rfc_process>-type.
    when cs-rfc_read.
      subtract 1 from nr_read_tasks.
    when cs-rfc_write.
      subtract 1 from nr_write_tasks.
  endcase.

  clear
      : <ls_rfc_process>-type
      .

endmethod.

method set_task_free.

  field-symbols
  : <ls_rfc_process> like line of dt_rfc_process
  , <ls_appl_write>  like line of dt_appl_write
  .

*--------------------------------------------------------------------*
* Присвоение занию статуса свободно
*--------------------------------------------------------------------*
  read table dt_rfc_process
        with key  task = task
        assigning <ls_rfc_process>.
*--------------------------------------------------------------------*

  case <ls_rfc_process>-type.

*--------------------------------------------------------------------*
* Освобождение задачи на чтение
*--------------------------------------------------------------------*
    when cs-rfc_read.
      subtract 1 from nr_read_tasks.

*--------------------------------------------------------------------*
* Освобождение задачи на запись
*--------------------------------------------------------------------*
    when cs-rfc_write.
      if dt_f_parallel = abap_false.
        read table dt_appl_write
             with key task = task
             assigning <ls_appl_write>.

        if sy-subrc = 0.
          clear <ls_appl_write>-task.
        endif.
        subtract 1 from nr_write_tasks.
      elseif dt_f_parallel = abap_true.
        subtract 1 from nr_write_tasks.
      endif.

  endcase.
*--------------------------------------------------------------------*

  add       1 to   nr_free_tasks.
  subtract  1 from nr_use_tasks.
  <ls_rfc_process>-st = cs-rfc_free.

  clear
  : <ls_rfc_process>-type
  .

endmethod.

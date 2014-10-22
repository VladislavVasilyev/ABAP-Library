method get_task_run.

  data
  : ls_appl_write like line of dt_appl_write
  , max_pbt_wps   type i
  , free_pbt_wps  type i
  .

  field-symbols
  : <ls_rfc_process> like line of dt_rfc_process
  , <ls_appl_write>  like line of dt_appl_write
  .

**********************************************************************
* Ожидание свободной задачи
**********************************************************************
  wait until nr_free_tasks > 0.

  read table     dt_rfc_process
       with key  st   = cs-rfc_free
       assigning <ls_rfc_process>.

  <ls_rfc_process>-st   = cs-rfc_run.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Получение макс кол-ва задач и количества свободных для использования
* задач
*--------------------------------------------------------------------*
  data
  : lv_max_tasks  type i
  , lv_free_tasks type i
  .

**********************************************************************
* Резервирование задачи
**********************************************************************
  <ls_rfc_process>-st   = cs-rfc_run.

  add       1 to   nr_use_tasks.
  subtract  1 from nr_free_tasks.

  if mode = cs-rfc_write." открываем задачу на запись
    if dt_f_parallel = abap_false.
      <ls_rfc_process>-type = cs-rfc_write.
      read table dt_appl_write
           with table key appset_id = i_appset_id
                          appl_id   = i_appl_id
           assigning <ls_appl_write>.

      if sy-subrc <> 0.
        ls_appl_write-appset_id = i_appset_id.
        ls_appl_write-appl_id   = i_appl_id.
        insert ls_appl_write into table dt_appl_write
               assigning <ls_appl_write>.
      endif.

      if <ls_appl_write>-task is not initial.
        wait until <ls_appl_write>-task is initial.
      endif.
      <ls_appl_write>-task = <ls_rfc_process>-task.
      add 1 to nr_write_tasks.
    else.
      <ls_rfc_process>-type = cs-rfc_write.
      add 1 to nr_write_tasks.
    endif.
  elseif mode = cs-rfc_read.
    <ls_rfc_process>-type = cs-rfc_read.
    add 1 to nr_read_tasks.
  endif.
*--------------------------------------------------------------------*

  check_wait_free_tasks( ).

  task = <ls_rfc_process>-task.

  get time stamp field cd_v__while_start.

endmethod.

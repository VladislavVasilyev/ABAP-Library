method CONSTRUCTOR.

  constants
    : task_name      type ty_name_rfc_task value 'RFC_0000'
    .

  data
    : ls_rfc_process like line of dt_rfc_process
    , nr_task        type i
    , n              type string
    , len            type i
    , off            type i
    , ls_rec         type ty_s_rfc_rec_task.
    .

  ls_rfc_process-st = cs-rfc_free.

  if num <= 0.
    nr_task = 1.
  elseif num > 4.
    nr_task = 4.
  else.
    nr_task = num.
  endif.

  do nr_task times.
    n = sy-index.
    condense n no-gaps.
    len = strlen( n ).
    off = 8 - len.

    ls_rfc_process-task = ls_rec-task = task_name.

    replace section offset off length len of
           : ls_rfc_process-task with n
           , ls_rec-task         with n
           .

    insert ls_rec into table dt_rfc_rec_task.
    append ls_rfc_process to dt_rfc_process.

    add 1 to nr_max_tasks.
  enddo.

  nr_free_tasks = nr_max_tasks.

endmethod.

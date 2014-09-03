method PRINT_LOG.
  data
     :  time_d                  type string
     ,  min                     type string
     ,  ls_rw_log               like line of ds_method-rw_log
     ,  l_message               type string
     ,  nr_rows                 type string
     ,  stat                    type string
     ,  time                    type string
     ,  rows                    type string
     ,  nr_pack                 type string
     ,  str                     type string
     ,  i                       type i
     ,  len                     type i
     ,  offset                  type i
     ,  lv_save_session         type i
     ,  l_div                   type string
     .

  check print_log = abap_true.

*--------------------------------------------------------------------*
* Печать основного лога
*--------------------------------------------------------------------*
  data l_time        type string.
  data l_packagesize type string.
  data l_task        type string.

  message e013(zmx_rb_logistics) into l_div. " разделитель
  write_log_pack( mode = cs-log_fl message = cs-log_div ).

  loop at dt_method
       into ds_method.

    l_packagesize = ds_method-packagesize.
    l_task        = do_rfc_task->nr_max_tasks.

    condense
      : l_packagesize no-gaps
      , l_task        no-gaps
      .

    l_time = get_log_time( start = ds_method-time_start
                           end   = ds_method-time_end   ).

    l_message =   'METHOD@-@$1@'        " method
                & '$2.@@@@@@'           " время старта и время выполнения
                & 'PACKAGESIZE(@$3@)@'  " packagesize
                & 'TASK(@$4@)@'         " task
                & 'LOG(@$5@)@'          " log
                .

    replace '$1' in l_message with ds_method-name.
    replace '$2' in l_message with l_time.
    replace '$3' in l_message with l_packagesize.
    replace '$4' in l_message with l_task.
    replace '$5' in l_message with ds_method-f_log.

    translate l_message using '@ '.

    " заголовок
    write_log_pack( mode = cs-log_pf message = l_message ).

    if ds_method-msgbox is not initial.
      write_log_pack( mode = cs-log_pf message = ds_method-msgbox ).
    endif.

    write_log_pack( mode = cs-log_pl message = l_div ).

*--------------------------------------------------------------------*
* вывести сообщения о чтении записи логов
*--------------------------------------------------------------------*
    " упорядочить по ссесиям
    sort ds_method-rw_log ascending by read_ses nr_pack type appset_id appl_id.

    loop at ds_method-rw_log
      into ls_rw_log. "DIR "DIM

      time = get_log_time( start = ls_rw_log-time_start end = ls_rw_log-time_end ).
      rows = get_log_rows( ls_rw_log ).
      stat = get_log_stat( ls_rw_log ).

      l_message = 'T1@'
                & 'T2@'
                & 'T3@@@@@@@@@@@@@@@@@@@@'
                & 'T4@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                & 'T5@'
                & 'T6'.

      " Номер пакета
      str = ls_rw_log-nr_pack. condense str no-gaps.
      nr_pack = '@@@@@@@@@@@'.
      if ls_rw_log-nr_pack > 0.
        concatenate nr_pack str into nr_pack.
      else.
        concatenate nr_pack 'DIR' into nr_pack.
      endif.
      i = strlen( nr_pack ) - 6.
      nr_pack = nr_pack+i(6).

      " Статус
      replace 'T1' in l_message with stat.
      " Номер пакета
      replace 'T2' in l_message with nr_pack.

      " Имя приложения
      str = ls_rw_log-appl_id. condense str no-gaps.
      find 'T3' in l_message match offset offset. len = strlen( str ).
      replace section offset offset length len of l_message with str.

      " Количество строк
      find 'T4' in l_message match offset offset. len = strlen( rows ).
      replace section offset offset length len of l_message with rows.

      " Время выполнения
      replace 'T5' in l_message with time.

      " Имя задачи
      replace 'T6' in l_message with ls_rw_log-rfc_task.

      translate l_message using '@ '.

      write_log_pack( mode = cs-log_fl message = l_message ).
    endloop.

    " разделитель
    write_log_pack( mode = cs-log_fl message = cs-log_div ).

  endloop.

endmethod.

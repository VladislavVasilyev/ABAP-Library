method if_uj_custom_logic~execute.

  data
  : lr_x__bdch_badi  type ref to cx_root
  , l_message         type string
  , lr_o__class       type ref to object
  , lr_o__badi        type ref to zif_bdch_badi
  .

  try.
      if ds_time_process-start is initial.
        get time stamp field ds_time_process-start.
      endif.

      get time stamp field ds_method-time_start.

      get_t_param( i_appset_id = i_appset_id
                   i_appl_id   = i_appl_id
                   it_param    = it_param ).

**********************************************************************
* Отмена запуска BADI из скрипт логики
**********************************************************************
      if ds_method-f_norun = abap_true.
        message e005(zmx_rb_logistics) into l_message with ds_method-name.
        write_log_pack( mode = cs-log_pl message = l_message  ).
        write_log_pack( mode = cs-log_pl message = cs-log_div ).
        return.
      endif.
*--------------------------------------------------------------------*

      zcl_debug=>stop_program( ds_method-f_debug ).

      try.
**********************************************************************
**********************************************************************
*           MAIN PROCESS
**********************************************************************
          create object lr_o__class type (ds_method-class).
          lr_o__badi  ?= lr_o__class.

          get reference of ct_data into lr_o__badi->ct_data.
          lr_o__badi->it_cv        = it_cv.
          lr_o__badi->it_param     = it_param.
          lr_o__badi->i_appl_id    = i_appl_id.
          lr_o__badi->i_appset_id  = i_appset_id.

          call method lr_o__class->(ds_method-name).
          et_message = lr_o__badi->et_message.

**********************************************************************

        catch cx_sy_dyn_call_illegal_method. " метод не найден
          mac__raise_logistics ex_cal_method ds_method-name '' '' ''.

        catch zcx_bdch_badi into lr_x__bdch_badi. " особая ситуация в методе
          raise exception type zcx_bdch_badi
                exporting textid    = zcx_bdch_badi=>ex_run_method
                          arg1      = ds_method-name
                          previous  = lr_x__bdch_badi.
      endtry.
*--------------------------------------------------------------------*

**********************************************************************
* Ожидание окончания всех RFC вызовов
**********************************************************************
      do_rfc_task->wait_end_all_task( ).
*--------------------------------------------------------------------*

      get time stamp field
      : ds_method-time_end
      , ds_time_process-end.
      .

      append ds_method to dt_method.
**********************************************************************
* Печать лога
**********************************************************************
      print_log( ds_method-f_log ).
*--------------------------------------------------------------------*

**********************************************************************
* Отправка сообщения
**********************************************************************
      send_email( ds_method-f_mail ). " отправка письма
*--------------------------------------------------------------------*


**********************************************************************
* Обработка особых ситуации
**********************************************************************
    catch zcx_bdch_badi into lr_x__bdch_badi. " supercatch

      try.
          message e004(zmx_rb_logistics) into l_message.
          write_log_pack( mode = cs-log_pl message = l_message ).

          while lr_x__bdch_badi is not initial.
            l_message = lr_x__bdch_badi->get_text( ).
            write_log_pack( mode = cs-log_pl message = l_message ).
            lr_x__bdch_badi = lr_x__bdch_badi->previous.
          endwhile.
        catch cx_root.
      endtry.

      write_log_pack( mode = cs-log_pl message = cs-log_div ).

      get time stamp field ds_time_process-end.
      send_email( i_send = abap_true i_error = abap_true ).

      raise exception type cx_uj_custom_logic
            exporting textid    = cx_uj_custom_logic=>info
                      datavalue = ` `.
  endtry.

endmethod.

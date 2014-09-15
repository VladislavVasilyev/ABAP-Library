method if_uj_custom_logic~execute.

  data
  : lr_o__run_logic   type ref to zcl_bdnl_run_logic
  , lr_x__bdnl_parser type ref to zcx_bdnl_parser
  , ld_s__error       type string
  , ld_t_message      type uj0_t_message
  , jobname         type tbtcm-jobname
  , ls_message      type uj0_s_message
  , lo_logger       type ref to cl_ujd_logger
  , lr_i__context     type ref to if_uj_context.
  .

  field-symbols
  : <ld_s__script> type ty_s__script
  .

*--------------------------------------------------------------------*
* GET JOB INFO
*--------------------------------------------------------------------*
  call function 'GET_JOB_RUNTIME_INFO'
    importing
      jobname         = jobname
    exceptions
      no_runtime_info = 1
      others          = 2.

  if sy-subrc <> 0.
*        raise exception type zcx_ujd_run_package
*          exporting textid = zcx_ujd_run_package=>ex_rp_invalid_get_rt_info.

  else.
    lo_logger = cl_ujd_package_context=>get_logger( ).
    ls_message-msgno = ujd0_cs_log_message-new_line.
    ls_message-message = `JobName: `.
    lo_logger->add_message( exporting is_message = ls_message ).
    ls_message-message =  jobname.
    lo_logger->add_message( exporting is_message = ls_message ).
    call method cl_ujd_custom_type=>reset_log.
  endif.
*--------------------------------------------------------------------*

  create object gr_o__badi_param
    exporting
      i_appset_id = i_appset_id
      i_appl_id   = i_appl_id
      it_param    = it_param
      it_cv       = it_cv.

  zcl_debug=>stop_program( gr_o__badi_param->gd_f__debug ).

*--------------------------------------------------------------------*
* Set_context
*--------------------------------------------------------------------*
  lr_i__context ?= cl_uj_context=>get_cur_context( ).

  call method zcl_bd00_context=>set_context
    exporting
      i_appset_id = lr_i__context->d_appset_id
      i_appl_id   = lr_i__context->d_appl_id
      i_s__user   = lr_i__context->ds_user.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* RUN LOGICS
*--------------------------------------------------------------------*
  try.
      create object lr_o__run_logic
        exporting
          i_o__param         = gr_o__badi_param
          i_f__parallel_task = gr_o__badi_param->gd_f__parallel_task
          i_v__num_tasks     = gr_o__badi_param->gd_v__num_tasks.

      lr_o__run_logic->run( ).

    catch zcx_bdnl_parser  into lr_x__bdnl_parser.

*      lr_t__error = lr_x__bdnl_parser->errortab.

      loop at lr_x__bdnl_parser->errortab
           into ld_s__error.

        call method cl_ujd_utility=>write_long_message
          exporting
            i_message  = ld_s__error
          changing
            ct_message = ld_t_message.
      endloop.

      cl_ujd_custom_type=>write_message_log( ld_t_message ).


      raise exception type cx_uj_custom_logic.

    catch zcx_bdnl_exception.

  endtry.
*--------------------------------------------------------------------*


endmethod.

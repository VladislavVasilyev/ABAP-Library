method if_rspc_execute~execute.

  data
  : lf_success      type uj_flg
  , l_uid           type sysuuid_25
  , lo_config       type ref to cl_ujd_config
  , lo_factory      type ref to cl_ujd_task_factory
  , lo_actor        type ref to zcl_bdch_new_logic
  , lo_error        type ref to cx_root
  , lo_runlogic     type ref to zcl_bdch_run_new_logic
  , lo_logger       type ref to cl_ujd_logger
  , ls_message      type uj0_s_message
  , jobname         type tbtcm-jobname
  .

  lo_logger = cl_ujd_package_context=>get_logger( ).

  call function 'RSSM_UNIQUE_ID'
    importing
      e_uni_idc25 = l_uid.

  e_instance = l_uid.

  try.
      create object lo_config
        exporting
          i_variant      = i_variant
          i_type         = `ZNEWLOGIC`
          i_jobcount     = i_jobcount
          it_processlist = i_t_processlist
          i_logid        = i_logid
          it_variables   = i_t_variables.

      call method lo_config->init.

      call method cl_ujd_custom_type=>add_task_name_msg
        exporting
          io_config = lo_config.

      create object lo_factory.

      create object lo_actor
        exporting
          io_task_factory = lo_factory
          io_config       = lo_config
          if_check_abort  = abap_true.

      call method lo_factory->init
        exporting
          io_config = lo_config
          io_actor  = lo_actor.

      lo_actor->if_ujd_actor~init( ).

      create object lo_runlogic
        exporting
          io_config = lo_config.

      call method lo_actor->if_ujd_actor~set_task
        exporting
          io_task = lo_runlogic.

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
        raise exception type zcx_ujd_run_package
          exporting textid = zcx_ujd_run_package=>ex_rp_invalid_get_rt_info.
      endif.

      ls_message-msgno = ujd0_cs_log_message-new_line.
      ls_message-message = `JobName: `.
      lo_logger->add_message( exporting is_message = ls_message ).
      ls_message-message =  jobname.
      lo_logger->add_message( exporting is_message = ls_message ).
      call method cl_ujd_custom_type=>reset_log.
*--------------------------------------------------------------------*

      call method lo_actor->if_ujd_actor~execute.

      call method cl_ujd_custom_type=>reset_log.

      e_state = 'G'.

    catch cx_root into lo_error.

      try.

          call method cl_ujd_custom_type=>set_error_status
            exporting
              io_config = lo_config.

          call method cl_ujd_custom_type=>write_exception_log
            exporting
              io_exception = lo_error.

        catch cx_root into lo_error.
          e_state = 'R'.
      endtry.

      e_state = 'R'.

  endtry.
endmethod.

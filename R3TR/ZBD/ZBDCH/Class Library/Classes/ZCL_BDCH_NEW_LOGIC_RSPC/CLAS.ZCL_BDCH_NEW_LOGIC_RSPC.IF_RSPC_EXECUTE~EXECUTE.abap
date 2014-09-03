method if_rspc_execute~execute.

  data: lf_success          type uj_flg,
        l_uid               type sysuuid_25,
        lo_config           type ref to cl_ujd_config,
        lo_factory          type ref to cl_ujd_task_factory,
        lo_actor            type ref to zcl_bdch_new_logic_rspc,
        lo_error            type ref to cx_root ,
        lo_runlogic         type ref to zcl_bdch_run_new_logic
        , ld_s__processlist   type rspc_s_processlist
        .

  call function 'RSSM_UNIQUE_ID'
    importing
      e_uni_idc25 = l_uid.

  e_instance = l_uid.

  try.
      create object lo_config
        exporting
          i_variant      = i_variant
          i_type         = `ZNEWLOGICR`
          i_jobcount     = i_jobcount
          it_processlist = i_t_processlist
          i_logid        = i_logid
          it_variables   = i_t_variables.

      call method lo_config->init.

      read table i_t_processlist
           with key variante = i_variant
           into ld_s__processlist transporting chain_id type.



*      call method cl_ujd_custom_type=>add_task_name_msg
*        exporting
*          io_config = lo_config.

*      create object lo_factory.
*
*      create object lo_actor
*        exporting
*          io_task_factory = lo_factory
*          io_config       = lo_config
*          if_check_abort  = abap_true.
*
*      call method lo_factory->init
*        exporting
*          io_config = lo_config
*          io_actor  = lo_actor.

*      lo_actor->if_ujd_actor~init( ).

      create object lo_runlogic
        exporting
          io_config = lo_config
          if_rspc   = abap_true.
*
*      call method lo_actor->if_ujd_actor~set_task
*        exporting
*          io_task = lo_runlogic.

      call method lo_runlogic->process_rspc( i_v__rspc_var = i_variant i_v__chain_id = ld_s__processlist-chain_id i_v__type = ld_s__processlist-type ).

*      call method lo_actor->if_ujd_actor~execute.

*      call method cl_ujd_custom_type=>reset_log.

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

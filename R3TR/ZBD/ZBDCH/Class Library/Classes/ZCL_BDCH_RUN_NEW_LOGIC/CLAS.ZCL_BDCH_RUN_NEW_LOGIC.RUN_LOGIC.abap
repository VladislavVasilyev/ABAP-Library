method run_logic.

  data
  : l_message               type string
  , l_logfile               type uj_docname
  , l_log_path              type string
  , l_module                type uj_module_id
  , lo_ex                   type ref to cx_uj_static_check
  , ld_v__string            type string
  , lr_o__run_logic         type ref to zcl_bdnl_run_logic
  , lr_x__bdnl_parser       type ref to zcx_bdnl_parser
  , ld_s__error             type string
  , ld_t_message            type uj0_t_message
  , l_path                  type uj_docname
  , ld_v__log_file          type string
  .

  field-symbols
  : <ld_s__cv> type ujk_s_cv
  .

  break-point.

  cl_ujk_model=>g_appset_id   = d_appset_id.
  cl_ujk_model=>g_appl_id     = d_appl_id.
  cl_ujk_model=>g_des_appl_id = d_appl_id.
  cl_ujk_model=>g_user_id     = d_user_id.
  cl_ujk_model=>g_log_path    = l_path.

  l_module = uj00_c_mod_name_dm.

  try.
      create object gr_o__replace
        exporting
          i_appset      = d_appset_id
          i_application = d_appl_id
          i_user        = d_user_id
          is_badi_param = ds_badi_param.

      concatenate '\ROOT\WEBFOLDERS\'
                   me->gr_o__replace->d_appset      '\'
                   me->gr_o__replace->d_application '\'
                   'PRIVATEPUBLICATIONS'            '\'
                   me->gr_o__replace->d_user        '\'
                   sy-datum(4)
                   sy-datum+4(2)
                   sy-datum+6
                   sy-uzeit(2)
                   sy-uzeit+2(2)
                   sy-uzeit+4                       '\'
                   'NEW_LOGIC.LOG'
             into l_path.

      ld_v__log_file = l_path.

      create object gr_o__badi_param
        exporting
          i_appset_id = d_appset_id
          i_appl_id   = d_appl_id
          it_param    = gr_o__replace->dt_hashtable
          it_cv       = it_k_cv
          ir_replace  = gr_o__replace.

      gr_o__badi_param->set_script( gd_t__logic_file  ).

      create object lr_o__run_logic
        exporting
          i_o__param         = gr_o__badi_param
          i_f__rspc          = gv_f__rspc
          i_f__parallel_task = gd_f__parallel_task
          i_v__num_tasks     = gd_v__num_tasks.

      print_log( ).

      lr_o__run_logic->run( ).

      ef_warning  = print_log_for_table( i_t__containers = lr_o__run_logic->gd_t__containers i_v__path = l_path ).

      call method cl_ujd_utility=>write_long_message
        exporting
          i_msgno    = ujd0_cs_log_message-runlogic_file    "'097'
          i_message  = ld_v__log_file
        changing
          ct_message = gt_message.

      ef_success = abap_true.

      if ef_warning = abap_true.
        call method cl_ujd_utility=>write_message
          exporting
            i_msgno    = ujd0_cs_log_message-package_warn
          changing
            ct_message = gt_message.
      endif.

    catch zcx_bdnl_parser into lr_x__bdnl_parser.
      ef_success = abap_false.

      loop at lr_x__bdnl_parser->errortab
           into ld_s__error.

        call method cl_ujd_utility=>write_long_message
          exporting
            i_message  = ld_s__error
          changing
            ct_message = gt_message.
      endloop.

    catch zcx_bdnl_exception.
      ef_success = abap_false.

    catch zcx_bd00_static_exception.
      ef_success = abap_false.

    catch cx_uj_static_check.
      ef_success = abap_false.

  endtry.

endmethod.

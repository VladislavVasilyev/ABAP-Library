method run_logic.

  data
*  : l_message               type string
*  : l_logfile               type uj_docname
*  : l_log_path              type string
*  : l_module                type uj_module_id
*  , lo_ex                   type ref to cx_uj_static_check
*  , ld_v__string            type string
  : lr_o__run_logic         type ref to zcl_bdnl_run_logic
  , lr_x__bdnl_parser       type ref to zcx_bdnl_parser
  , ld_s__error             type string
*  , ld_t_message            type uj0_t_message
  , l_path                  type uj_docname
  , ld_v__log_file          type string
  , lr_x__statick           type ref to cx_static_check
  , lr_x__dynamic           type ref to cx_dynamic_check
  , lr_x__root              type ref to cx_root
  , lr_x__work_cycle        type ref to zcx_bdnl_work_cycle
  , lr_x__work_func         type ref to zcx_bdnl_work_func
  , lr_x__work_rule         type ref to zcx_bdnl_work_rule
  , lr_x__create_rule       type ref to zcx_bd00_create_rule
*  , lr_x__bdnl_exc          type ref to zcx_bdnl_exception
  , ld_v__value             type string
  .

  field-symbols
*  : <ld_s__cv>              type ujk_s_cv
  : <ld_s__bindparam>       type abap_parmbind
  , <ld_v__value>           type any
  .

  break-point.

  cl_ujk_model=>g_appset_id   = d_appset_id.
  cl_ujk_model=>g_appl_id     = d_appl_id.
  cl_ujk_model=>g_des_appl_id = d_appl_id.
  cl_ujk_model=>g_user_id     = d_user_id.
  cl_ujk_model=>g_log_path    = l_path.

*  l_module = uj00_c_mod_name_dm.

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
                   'VCORE.LOG'
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

      ef_warning  = print_log_for_table( i_v__path = l_path ).

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

    catch zcx_bdnl_exception into lr_x__root.
      ef_success = abap_false.

      while lr_x__root is bound.
        ld_s__error = lr_x__root->get_text( ).
        print_log> gt_message ld_s__error.
        concatenate `X ` ld_s__error into ld_s__error.
        mprint> ld_s__error.

        lr_x__root = lr_x__root->previous.

      endwhile.

      message s048(zbdnl).
      message s035(zbdnl).


    catch zcx_bdnl_work_rule  into lr_x__work_rule.

      lr_x__root = lr_x__work_rule.

      while lr_x__root is bound.
        ld_s__error = lr_x__root->get_text( ).
        print_log> gt_message ld_s__error.
        concatenate ` X X X ` ld_s__error into ld_s__error.
        mprint> ld_s__error.

        lr_x__root = lr_x__root->previous.

        try.
            check lr_x__root is bound.
            lr_x__create_rule ?= lr_x__root.
            ld_s__error = lr_x__create_rule->line.
            print_log> gt_message ld_s__error.
            concatenate ` X X X ` ld_s__error into ld_s__error.
            mprint> ld_s__error.
            ld_s__error = lr_x__create_rule->message.
            print_log> gt_message ld_s__error.
            concatenate ` X X X ` ld_s__error into ld_s__error.
            mprint> ld_s__error.

            lr_x__root = lr_x__create_rule->previous.
          catch cx_sy_move_cast_error.
        endtry.

      endwhile.

      print_log> gt_message   `------------------------------------------------------------`.
      message s050(zbdnl).
      message s049(zbdnl).
      message s048(zbdnl).
      message s035(zbdnl).

    catch zcx_bdnl_work_cycle into lr_x__work_cycle.
      ld_s__error = lr_x__work_cycle->get_text( ).
*      break-point.
      print_log> gt_message
      : ld_s__error
      , `Rows:`
      , zcx_bdnl_work_cycle=>line
      .

      concatenate ` X X X ` ld_s__error into ld_s__error.
      mprint> ld_s__error.

      concatenate ` X X X ` `Rows:`  into ld_s__error.
      mprint> ld_s__error.

      concatenate ` X X X ` zcx_bdnl_work_cycle=>line  into ld_s__error.
      mprint> ld_s__error.


      lr_x__root = lr_x__work_cycle->previous.

      try.
          lr_x__work_func ?= lr_x__work_cycle->previous.
          ld_s__error      = lr_x__work_func->get_text( ).
          print_log>       gt_message ld_s__error.
          concatenate ` X X X ` ld_s__error into ld_s__error.
          mprint> ld_s__error.
          " печать param
          loop at lr_x__work_func->bindparam assigning <ld_s__bindparam> where kind = cl_abap_classdescr=>exporting.
            ld_s__error = <ld_s__bindparam>-name.
            concatenate ld_s__error ` = ` into ld_s__error.
            assign <ld_s__bindparam>-value->* to <ld_v__value>.

            ld_v__value = <ld_v__value>.
            concatenate ld_s__error ld_v__value into ld_s__error.
            print_log> gt_message ld_s__error.
            concatenate ` X X X ` ld_s__error into ld_s__error.
            mprint> ld_s__error.
          endloop.

          lr_x__root      = lr_x__work_func->previous.

        catch cx_sy_move_cast_error.
      endtry.

      while lr_x__root is bound.
        ld_s__error = lr_x__root->get_text( ).
        print_log> gt_message ld_s__error.
        concatenate ` X X X ` ld_s__error into ld_s__error.
        mprint> ld_s__error.

        lr_x__root = lr_x__root->previous.

      endwhile.

      print_log> gt_message   `------------------------------------------------------------`.
      message s050(zbdnl).
      message s049(zbdnl).
      message s048(zbdnl).
      message s035(zbdnl).

    catch cx_static_check into lr_x__statick.
      ef_success = abap_false.
*      break-point.

      ld_s__error = lr_x__statick->get_text( ).

      call method cl_ujd_utility=>write_long_message
        exporting
          i_message  = ld_s__error
        changing
          ct_message = gt_message.

    catch cx_dynamic_check into lr_x__dynamic.
      ef_success = abap_false.
*      break-point.

      ld_s__error = lr_x__dynamic->get_text( ).

      call method cl_ujd_utility=>write_long_message
        exporting
          i_message  = ld_s__error
        changing
          ct_message = gt_message.

    catch cx_root into lr_x__root.

      while lr_x__root is bound.
        ld_s__error = lr_x__root->get_text( ).

        call method cl_ujd_utility=>write_long_message
          exporting
            i_message  = ld_s__error
          changing
            ct_message = gt_message.

        lr_x__root = lr_x__root->previous.

      endwhile.
  endtry.

endmethod.

method if_uj_custom_logic~execute.

  data
  : lr_o__run_logic   type ref to zcl_bdnl_run_logic
  , lr_x__bdnl_parser type ref to zcx_bdnl_parser
  , ld_s__error       type string
  , ld_t_message      type uj0_t_message
  .

  field-symbols
  : <ld_s__script> type ty_s__script
  .

  create object gr_o__badi_param
    exporting
      i_appset_id = i_appset_id
      i_appl_id   = i_appl_id
      it_param    = it_param
      it_cv       = it_cv.

  zcl_debug=>stop_program( gr_o__badi_param->gd_f__debug ).

*--------------------------------------------------------------------*
* RUN LOGICS
*--------------------------------------------------------------------*
  try.

      create object lr_o__run_logic
        exporting
          i_o__param = gr_o__badi_param.

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

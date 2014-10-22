function zbd00_rfc_bpc_write .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_APPSET_ID) TYPE  UJ_APPSET_ID
*"     VALUE(I_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_MODE) TYPE  ZRB_WRITE_BACK_MODE
*"     VALUE(I_BPC_USER) TYPE  UJ0_S_USER OPTIONAL
*"  EXPORTING
*"     VALUE(ET_MESSAGE) TYPE  UJ0_T_MESSAGE
*"     VALUE(ES_STATUS_RECORDS) TYPE  UJR_S_STATUS_RECORDS
*"     VALUE(E_TIME_END) TYPE  TZNTSTMPL
*"     VALUE(E_CNT_RAISE_WRITE) TYPE  I
*"  TABLES
*"      I_T_RFCDATA TYPE  RSDRI_T_RFCDATA OPTIONAL
*"      I_T_FIELD TYPE  RSDP0_T_FIELD OPTIONAL
*"  EXCEPTIONS
*"      ERROR_WRITE_BACK
*"      ERROR_STATIC_CHECK
*"      X_MESSAGE
*"----------------------------------------------------------------------

  break-point id zbd00.
*  zcl_debug=>stop_program( ).
*╔═══════════════════════════════════════════════════════════════════╗
*║ Context                                                           ║
*╠═══════════════════════════════════════════════════════════════════╣
  data
  : lo_uj_context          type ref to if_uj_context
  , ls_user                type uj0_s_user
  , lr_x_write_back        type ref to cx_root
  .

  ls_user = i_bpc_user.
  cl_uj_context=>set_cur_context(
              i_appset_id = i_appset_id
              i_appl_id   = i_appl_id
              is_user     = ls_user ).


*  lo_uj_context ?= cl_uj_context=>get_cur_context( ).
*  lo_uj_context->switch_to_srvadmin( ).
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Настройки                                                         ║
*╠═══════════════════════════════════════════════════════════════════╣
  data
  : lf_default_logic   type uj_flg
  , lf_update_audit    type uj_flg
  , lf_duplicate       type uj_flg
  , lf_mdata_check     type uj_flg
  , lf_sign_trans      type uj_flg
  , lf_suppress_zero   type uj_flg
  , lf_bypass_badi     type uj_flg
  , lf_bypass_lock     type uj_flg
  , lf_calc_delta      type uj_flg
  , wa_work_status     type ujr_s_work_status
  , ld_s__message      type uj0_s_message
  .

  wa_work_status-module_id   = uj00_c_mod_name_dm.
  case i_mode.
    when 'A'. " Вставить записи игнорируя дубликаты
      wa_work_status-blockaction = uj00_c_block_action_obey.
      lf_default_logic = abap_false.
      lf_update_audit  = abap_true.
      lf_duplicate     = abap_false.
      lf_mdata_check   = abap_false.
      lf_sign_trans    = abap_false.
      lf_suppress_zero = abap_false.
      lf_bypass_badi   = abap_false.
      lf_bypass_lock   = abap_false.
      lf_calc_delta    = abap_false.
    when 'M'. " Перезапись дубликатов
      wa_work_status-blockaction = uj00_c_block_action_obey.
      lf_default_logic = abap_false.
      lf_update_audit  = abap_true.
      lf_duplicate     = abap_true.
      lf_mdata_check   = abap_false.
      lf_sign_trans    = abap_false.
      lf_suppress_zero = abap_false.
      lf_bypass_badi   = abap_false.
      lf_bypass_lock   = abap_true.
      lf_calc_delta    = abap_true.
  endcase.
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Обработка данных                                                  ║
*╠═══════════════════════════════════════════════════════════════════╣
  data
     : lo_model     type ref to zcl_bd00_model
     , lr_data      type ref to data
     , lr_data_err  type ref to data
     .

  field-symbols
      : <lt_data>     type standard table
      , <lt_data_err> type standard table
      .

  lo_model = zcl_bd00_model=>get_model(
                i_appset_id = i_appset_id
                i_appl_id   = i_appl_id
                i_type_pk   = zbd0c_ty_tab-std_non_unique_dk ).

  create data lr_data type handle lo_model->gd_s__handle-tab-appl_name.
  create data lr_data_err type handle lo_model->gd_s__handle-tab-appl_name.

  assign lr_data->*     to <lt_data>.
  assign lr_data_err->* to <lt_data_err>.

  " распаковка данных
  call function 'ZBD00_DATA_UNWRAP'
    exporting
      i_t_rfcdata = i_t_rfcdata[]
    changing
      c_t_data    = <lt_data>.
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Запись данных в приложение BPC                                    ║
*╠═══════════════════════════════════════════════════════════════════╣
  data " Параметры для записи WRITE-BACK
  : lo_wb_main_int          type ref to cl_ujr_write_back
  , lo_ref                  type ref to cx_root
  , ld_v__cnt_raise_write  type i
  .

  while 1 = 1. "ld_v__cnt_raise_write < 20.
    try.
        create object lo_wb_main_int.
        call method lo_wb_main_int->write_back_int
          exporting
            is_work_status    = wa_work_status
            i_default_logic   = lf_default_logic
            i_update_audit    = lf_update_audit
            i_duplicate       = lf_duplicate
            i_mdata_check     = lf_mdata_check
            i_sign_trans      = lf_sign_trans
            i_suppress_zero   = lf_suppress_zero
            i_bypass_badi     = lf_bypass_badi
            i_bypass_lock     = lf_bypass_lock
            i_calc_delta      = lf_calc_delta
            it_array          = <lt_data>
          importing
            et_message        = et_message
            es_status_records = es_status_records
            et_error_records  = <lt_data_err>.
      catch cx_ujr_write_back into lr_x_write_back.
        while lr_x_write_back is not initial.
          ld_s__message-message = lr_x_write_back->get_text( ).
          append  ld_s__message to et_message.
*        message lr_x_write_back type 'I' into ET_MESSAGE .
          lr_x_write_back = lr_x_write_back->previous.
        endwhile.

        add 1 to ld_v__cnt_raise_write.
        continue.

        raise error_write_back.
      catch cx_uj_db_error
            cx_uja_admin_error into lo_ref.
        raise x_message.
      catch cx_uj_static_check.
        raise error_static_check.
    endtry.

    exit.
  endwhile.

*╚═══════════════════════════════════════════════════════════════════╝
  e_cnt_raise_write = ld_v__cnt_raise_write.
  sort et_message ascending.
  delete adjacent duplicates from et_message.

  get time stamp field e_time_end.

endfunction.

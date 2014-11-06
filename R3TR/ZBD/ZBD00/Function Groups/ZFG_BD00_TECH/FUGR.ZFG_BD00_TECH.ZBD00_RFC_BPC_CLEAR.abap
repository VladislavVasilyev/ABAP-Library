function zbd00_rfc_bpc_clear.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_APPSET_ID) TYPE  UJ_APPSET_ID
*"     VALUE(I_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_TYPE_PK) TYPE  ZBD00_S_BPC_DIM-TYPE DEFAULT '001'
*"     VALUE(IF_AUTO_SAVE) TYPE  RS_BOOL DEFAULT ABAP_FALSE
*"     VALUE(IT_ALIAS) TYPE  ZBD00_T_ALIAS OPTIONAL
*"     VALUE(IT_RANGE) TYPE  UJ0_T_SEL OPTIONAL
*"     VALUE(IT_DIM_LIST) TYPE  ZBD00_T_CH_KEY OPTIONAL
*"     VALUE(IF_SUPPRESS_ZERO) TYPE  RS_BOOL DEFAULT ABAP_TRUE
*"     VALUE(I_PACKAGESIZE) TYPE  I OPTIONAL
*"     VALUE(IF_INVERT) TYPE  RS_BOOL DEFAULT ABAP_FALSE
*"     VALUE(I_DESTINATION) TYPE  STRING OPTIONAL
*"     VALUE(I_TASK_NUM) TYPE  I OPTIONAL
*"     VALUE(I_LOOP) TYPE  RS_BOOL OPTIONAL
*"  EXPORTING
*"     VALUE(E_NUM_READ) TYPE  I
*"     VALUE(E_NUM_WRITE) TYPE  UJR_S_STATUS_RECORDS
*"     VALUE(E_RAISE_WB) TYPE  I
*"  TABLES
*"      ET_MESSAGE TYPE  UJ0_T_MESSAGE OPTIONAL
*"  EXCEPTIONS
*"      ERR_BD00_CREATE_OBJ
*"----------------------------------------------------------------------

  data:
        lr_o__target          type ref to zcl_bd00_appl_table
      , ld_t__log_read        type zbd0t_t__log_read
      , ld_t__log_write       type zbd0t_t__log_write
      , num_read              type i
      , num_write             type ujr_s_status_records
      , lv_raise_wb           type i
      , e_message             type uj0_t_message
      , lr_i__context         type ref to if_uj_context
      , lv_task_num           type i
      , gr_o__rfc_task        type ref to zcl_bd00_rfc_task
      .
  field-symbols
  : <ld_s__log_read>  like line of ld_t__log_read
  , <ld_s__log_write> like line of ld_t__log_write
*  , <fs_message>      type uj0_s_message
  .

  data lv type i .
  if i_loop = abap_true.
    do.
      if lv is not initial .
        exit.
      endif.
    enddo.
  endif.

* set user for standard and z context
  lr_i__context ?= cl_uj_context=>get_cur_context( ).
  lr_i__context->switch_to_srvadmin( ).

  call method zcl_bd00_context=>set_context
    exporting
      i_appset_id = i_appset_id
      i_appl_id   = i_appl_id
      i_s__user   = lr_i__context->ds_user.

  try.
      cl_uj_context=>set_cur_context( i_appset_id  = i_appset_id
      is_user      = lr_i__context->ds_user
      i_appl_id    = i_appl_id ).
    catch cx_uj_obj_not_found.
      raise err_bd00_create_obj.
  endtry.

* Set number of parallel RFC-processes
  if i_task_num is initial.
    lv_task_num = 4.
  else.
    lv_task_num = i_task_num .
  endif.
  write: / `Parallel tasks =` , lv_task_num .

  create object gr_o__rfc_task
    exporting
      num           = lv_task_num
      parallel_task = abap_true.

  clear lr_o__target .
  try.
      create object lr_o__target
        exporting
          i_appset_id         = i_appset_id
          i_appl_id           = i_appl_id
*    i_type_pk           = I_TYPE_PK
*    if_auto_save        = IF_AUTO_SAVE
*    it_alias            = IT_ALIAS
          it_range            = it_range
*    it_dim_list         = it_dim_list
*    it_const            =
*    if_suppress_zero    = IF_SUPPRESS_ZERO
*    i_packagesize       = i_packagesize
          if_invert           = if_invert
*    i_destination       =
          .
    catch zcx_bd00_create_obj .
      raise err_bd00_create_obj.
  endtry.

  while lr_o__target->next_pack( zbd0c_read_mode-pack ) eq zbd0c_read_pack .
    lr_o__target->write_back( abap_true ).
  endwhile.
  zcl_bd00_rfc_task=>wait_end_all_task( ).

* Log from clearing class
  clear: ld_t__log_read ,
  ld_t__log_write ,
  num_read ,
  num_write ,
  lv_raise_wb ,
  e_message .

  call method lr_o__target->get_log
    importing
      e_t__read = ld_t__log_read.

  call method lr_o__target->get_log
    importing
      e_t__write = ld_t__log_write.

  loop at ld_t__log_read assigning <ld_s__log_read>.
    add <ld_s__log_read>-sup_rec to num_read.
  endloop.

  loop at ld_t__log_write assigning <ld_s__log_write>.
    add <ld_s__log_write>-status_records-nr_submit to num_write-nr_submit.
    add <ld_s__log_write>-status_records-nr_fail to num_write-nr_fail.
    add <ld_s__log_write>-status_records-nr_success to num_write-nr_success.
    add <ld_s__log_write>-cnt_raise_write to lv_raise_wb.
    append lines of <ld_s__log_write>-message to e_message.
  endloop.

  sort e_message.
  delete adjacent duplicates from e_message.

  e_num_read   = num_read .
  e_num_write  = num_write .
  e_raise_wb   = lv_raise_wb .
  et_message[] = e_message[] .

endfunction.

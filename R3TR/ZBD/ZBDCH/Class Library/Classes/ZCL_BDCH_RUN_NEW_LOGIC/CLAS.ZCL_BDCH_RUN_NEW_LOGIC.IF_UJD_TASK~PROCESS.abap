method if_ujd_task~process.

  clear
  : ef_success
  , et_message.

  data
  : lt_filter_tab     type ujd_th_dim_mem
  , l_filter_str      type string
  , lf_warning        type uj_flg
  , lt_k_cv           type ujk_t_cv  " initial means to deal with the whole cube
  , lr_i__context     type ref to if_uj_context.

  get time stamp field gd_v__time_start.

*--------------------------------------------------------------------*
* Get filter rule for run logic package
*--------------------------------------------------------------------*
  call method me->get_parameter.

  call method me->get_filter
    exporting
      i_selection       = d_selection
      i_memberselection = d_memberselection
    importing
      et_filter_tab     = lt_filter_tab
      e_filter_str      = l_filter_str.

  call method me->get_cv_logic
    exporting
      it_filter_tab = lt_filter_tab
    importing
      et_k_cv       = lt_k_cv.

  call method me->set_badi_param
    exporting
      i_para = l_filter_str.


  zcl_debug=>stop_program( gd_f__debug ).
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
* run logic
*--------------------------------------------------------------------*
  call method me->run_logic
    exporting
      it_k_cv    = lt_k_cv
    importing
      ef_success = ef_success
      ef_warning = lf_warning.
*--------------------------------------------------------------------*

  get time stamp field gd_v__time_end.

  case d_sendmail.
    when 1.
      if ef_success = abap_false or lf_warning = abap_true.
        send_email( if_succes = ef_success if_warning = lf_warning if_log = dv_f__logmail ).
      endif.
    when 2.
      send_email( if_succes = ef_success if_warning = lf_warning  if_log = dv_f__logmail ).
    when  others.
  endcase.

  call method send_email
    exporting
      if_succes  = ef_success
      if_warning = lf_warning
      if_log     = `1`
      if_job     = abap_true.

  et_message = gt_message.

endmethod.

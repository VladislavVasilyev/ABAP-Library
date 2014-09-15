method process_rspc.

  clear
  : ef_success
  , et_message.

  data
  : lt_filter_tab           type ujd_th_dim_mem
  , l_filter_str            type string
  , lf_warning              type uj_flg
  , lt_k_cv                 type ujk_t_cv  " initial means to deal with the whole cube
  , ld_s__user              type uj0_s_user
  .

  gd_v__rspc_var  = i_v__rspc_var.
  gd_v__chain_id  = i_v__chain_id.
  gd_v__rspc_type = i_v__type.

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

  ld_s__user-user_id = d_user_id.

  call method zcl_bd00_context=>set_context
    exporting
      i_appset_id = d_appset_id
      i_appl_id   = d_appl_id
      i_s__user   = ld_s__user.

*--------------------------------------------------------------------*
* run logic
*--------------------------------------------------------------------*
  zcl_debug=>stop_program( gd_f__debug ).

  if gd_f__norun = abap_false.
    call method me->run_logic
      exporting
        it_k_cv    = lt_k_cv
      importing
        ef_success = ef_success
        ef_warning = lf_warning.
  else.
    ef_success = abap_true.
  endif.
*--------------------------------------------------------------------*

  get time stamp field gd_v__time_end.

  case d_sendmail.
    when 1.
      if ef_success = abap_false or lf_warning = abap_true.
        send_email( if_succes = ef_success if_warning = lf_warning if_log = dv_f__logmail ).
      endif.
    when 2.
      send_email( if_succes = ef_success if_warning = lf_warning if_log = dv_f__logmail ).
    when  others.
  endcase.

  if gv_f__rspc = abap_true.
    call method send_email
      exporting
        if_succes  = ef_success
        if_warning = lf_warning
        if_log     = `1`
        if_job     = abap_true.
  endif.

  et_message = gt_message.

  if ef_success = abap_false.
    raise exception type cx_uj_static_check.
  endif.

endmethod.

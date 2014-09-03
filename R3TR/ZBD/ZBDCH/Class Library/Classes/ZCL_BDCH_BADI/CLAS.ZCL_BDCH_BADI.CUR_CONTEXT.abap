method CUR_CONTEXT.
  data
      : lo_security    type ref to cl_uje_check_security
      , lv_user	       type uj0_s_user
      , lo_uj_context  type ref to if_uj_context
      .

  if i_appset_id is not supplied and
     i_appl_id   is not supplied.
    " востановление
    check: gt_cur_context-context is not initial.

    cl_uj_context=>set_cur_context(
      i_appset_id = gt_cur_context-context->d_appset_id
      is_user     = gt_cur_context-context->ds_user
      i_appl_id   = gt_cur_context-context->d_appl_id ).

    clear gt_cur_context.
  else.
    " сохранение и создание
    check i_appset_id is supplied and i_appl_id is supplied.

    lo_uj_context ?= cl_uj_context=>get_cur_context( ).

    check not lo_uj_context->d_appset_id = i_appset_id or
          not lo_uj_context->d_appl_id   = i_appl_id.

    gt_cur_context-context  ?= lo_uj_context.
    gt_cur_context-appset_id = lo_uj_context->d_appset_id.
    gt_cur_context-appl_id   = lo_uj_context->d_appl_id.

    create object lo_security.
    lv_user-user_id = lo_security->d_server_admin_id.

    cl_uj_context=>set_cur_context(
      i_appset_id = i_appset_id
      i_appl_id   = i_appl_id
      is_user     = lv_user ).

  endif.
endmethod.

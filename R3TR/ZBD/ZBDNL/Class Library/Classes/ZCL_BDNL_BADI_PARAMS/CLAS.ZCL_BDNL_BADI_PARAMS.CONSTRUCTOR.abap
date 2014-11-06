method constructor.

  gd_v__appset_id = i_appset_id.
  gd_v__appl_id   = i_appl_id.
  gd_t__param     = it_param.
  gd_t__cv        = it_cv.

  if ir_replace is not bound.
    create object gr_o__replace
      exporting
        i_appset      = i_appset_id
        i_application = i_appl_id
        i_user        = cl_ujk_model=>g_user_id.
  else.
    gr_o__replace   = ir_replace.
  endif.

  call method set_param.

endmethod.

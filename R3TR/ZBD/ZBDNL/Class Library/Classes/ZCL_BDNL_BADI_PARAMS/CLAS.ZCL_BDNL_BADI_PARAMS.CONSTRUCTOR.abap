method constructor.

  gd_v__appset_id = i_appset_id.
  gd_v__appl_id   = i_appl_id.
  gd_t__param     = it_param.
  gd_t__cv        = it_cv.
  gr_o__replace   ?= ir_replace.

  call method set_param.

endmethod.

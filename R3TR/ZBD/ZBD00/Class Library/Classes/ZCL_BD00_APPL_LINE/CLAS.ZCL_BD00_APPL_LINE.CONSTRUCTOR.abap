method constructor.
  call method super->constructor.

  create data cline type handle io_model->gd_s__handle-st-tech_name.
  line         = cline.
  f_ref_line   = abap_false.
  gr_o__model  = io_model.
  gr_o__line      = me.

  set_const( it_const ).

  data
  : ld_s__object_reestr type ty_s_object_reestr.

  ld_s__object_reestr-object ?= me.

  insert ld_s__object_reestr into table cd_t__object_reestr.
endmethod.

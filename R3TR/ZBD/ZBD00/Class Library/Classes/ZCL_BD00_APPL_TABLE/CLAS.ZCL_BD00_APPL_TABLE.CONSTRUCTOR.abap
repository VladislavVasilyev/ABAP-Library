method constructor.

  data
  : ld_s__class_reg           type ty_s_class_reg
  , ld_s__link_reestr         like line of gd_t__reestr_link
  .

  call method super->constructor.

  gd_f__auto_save = if_auto_save.

  if cd_s__infocube-flag = abap_false.
    if cd_s__appl_cust-flag = abap_false.
      gr_o__model ?= zcl_bd00_model=>get_model( it_dim_list = it_dim_list
                                                i_appset_id = i_appset_id
                                                i_appl_id   = i_appl_id
                                                i_type_pk   = i_type_pk
                                                it_alias    = it_alias ).
    else.
      if cd_s__appl_cust-dimension is initial.
        gr_o__model ?= zcl_bd00_model=>get_model_cust_appl( it_dim_list = it_dim_list
                                                            i_appset_id = i_appset_id
                                                            i_type_pk   = i_type_pk
                                                            it_alias    = it_alias ).
      else.
        gr_o__model ?= zcl_bd00_model=>get_model_dimension( it_dim_list = it_dim_list
                                                            i_dimension = cd_s__appl_cust-dimension
                                                            i_appset_id = i_appset_id
                                                            i_type_pk   = i_type_pk
                                                            it_alias    = it_alias ).

      endif.
    endif.
  else.
    gr_o__model ?= zcl_bd00_model=>get_model_infocube( it_dim_list = it_dim_list
                                                       it_kyf_list = cd_s__infocube-kyf
                                                       i_infocube  = cd_s__infocube-name
                                                       i_type_pk   = i_type_pk
                                                       it_alias    = it_alias ).
  endif.

  create data gr_t__table type handle gr_o__model->gd_s__handle-tab-tech_name.

  create object gr_o__line
    exporting
      io_model = gr_o__model.

  gr_o__line->set_appl_table( ).

  create object gr_o__process_data
    exporting
      io_appl_table    = me
      it_range         = it_range
      iv_packagesize   = i_packagesize
      if_suppress_zero = if_suppress_zero
      if_invert        = if_invert.

*  append gr_o__process_data->go_log to cd_t__log_object.

  gr_o__table = me.

  set_const( it_const ).

* регистрация правила по умолчанию
  ld_s__link_reestr-id                = gd_v__default_rule = get_rule_id( ).
  ld_s__link_reestr-type              = zcl_bd00_int_table=>method-search.
  ld_s__link_reestr-main             ?= me.

  insert ld_s__link_reestr into table gd_t__reestr_link.

  ld_s__class_reg-id        = gd_v__default_rule.
  ld_s__class_reg-main     ?= me.
  ld_s__class_reg-class     = zcl_bd00_int_table=>create_read( gd_v__default_rule ).
  insert ld_s__class_reg into table gd_t__class_reg.

  data
  : ld_s__object_reestr type ty_s_object_reestr.

  ld_s__object_reestr-object ?= me.

  insert ld_s__object_reestr into table cd_t__object_reestr.

  clear: cd_s__infocube.

endmethod.

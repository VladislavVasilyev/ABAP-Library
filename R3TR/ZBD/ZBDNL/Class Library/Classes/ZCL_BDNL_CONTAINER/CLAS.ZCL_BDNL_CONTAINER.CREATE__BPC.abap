method create__bpc.

  data
  : ld_f__supresszero                 type rs_bool
  .

  if gd_f__init = abap_true.
    if i_v__package_size = -1 and gd_v__read_mode = zbd0c_read_mode-arfc.
      " сбросить индекс
      gr_o__container->reset_index( ).
      e_f__create = abap_false.
      return.
    endif.
  endif.

  if gd_s__param-notsupresszero = abap_true.
    ld_f__supresszero = abap_false.
  else.
    ld_f__supresszero = abap_true.
  endif.

  if gr_o__container is bound.
    gr_o__container->clear( ).
  endif.

  create object gr_o__container
    exporting
      i_appset_id      = gd_s__param-appset_id
      i_appl_id        = gd_s__param-appl_id
      i_type_pk        = gd_s__param-tech_type_table
      it_dim_list      = gd_s__param-dim_list
      it_alias         = gd_s__param-alias
      it_range         = gd_s__param-range
      i_packagesize    = i_v__package_size
      if_suppress_zero = ld_f__supresszero
      i_destination    = gd_s__param-destination.

  if i_v__package_size = -1.
    gd_v__read_mode = zbd0c_read_mode-arfc.
    gr_o__container->next_pack( gd_v__read_mode ).
    gd_f__init = abap_true.
  else.
    gd_v__read_mode = zbd0c_read_mode-pack.
    gd_f__init      = abap_false.
  endif.

*  gd_v__packagesize = i_v__package_size.
  e_f__create = abap_true.

endmethod.

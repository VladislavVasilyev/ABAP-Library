method create__bpcgen.

  if gd_f__init = abap_true.
    if i_v__package_size = -1 and gd_v__read_mode = zbd0c_read_mode-genfull.
      " сбросить индекс
      gr_o__container->reset_index( ).
      e_f__create = abap_false.
      return.
    endif.
  endif.

  if gr_o__container is bound.
    gr_o__container->clear( ).
  endif.

  call method zcl_bd00_appl_table=>get_appl_cust
    exporting
      it_alias      = gd_s__param-alias
      it_range      = gd_s__param-range
      i_appset_id   = gd_s__param-appset_id
      i_type_pk     = gd_s__param-tech_type_table
      it_dim_list   = gd_s__param-dim_list
      i_packagesize = i_v__package_size
    receiving
      e_infocube    = gr_o__container.

  if i_v__package_size = -1.
    gd_v__read_mode = zbd0c_read_mode-genfull.
    gr_o__container->next_pack( zbd0c_read_mode-genfull ).
    gd_f__init = abap_true.
  else.
    gd_v__read_mode = zbd0c_read_mode-genpack.
    gd_f__init      = abap_false.
  endif.

  gd_v__packagesize = i_v__package_size.
  e_f__create = abap_true.

endmethod.

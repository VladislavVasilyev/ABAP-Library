method create__bp.

  data
  : ld_v__infocube                    type rsinfoprov
  , ld_f__supresszero                 type rs_bool
  .

  ld_v__infocube = gd_s__param-appl_id.

  if gd_f__init = abap_true.
    if i_v__package_size = -1 and gd_v__read_mode = zbd0c_read_mode-full.
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

  call method zcl_bd00_appl_table=>get_infocube
    exporting
      it_range         = gd_s__param-range
      it_dim_list      = gd_s__param-dim_list
      i_packagesize    = i_v__package_size
      i_infocube       = ld_v__infocube
      it_kyf_list      = gd_s__param-kyf_list
      i_type_pk        = gd_s__param-tech_type_table
      if_suppress_zero = ld_f__supresszero
    receiving
      e_infocube       = gr_o__container.

  if i_v__package_size = -1.
    gd_v__read_mode = zbd0c_read_mode-full.
    gr_o__container->next_pack( zbd0c_read_mode-full ).
    gd_f__init = abap_true.
  else.
    gd_v__read_mode = zbd0c_read_mode-pack.
    gd_f__init      = abap_false.
  endif.

  gd_v__packagesize = i_v__package_size.
  e_f__create = abap_true.

endmethod.

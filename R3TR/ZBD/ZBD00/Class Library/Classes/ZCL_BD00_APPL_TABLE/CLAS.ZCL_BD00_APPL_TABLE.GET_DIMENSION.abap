method get_dimension.

  data
  : ld_t__alias     type zbd00_t_alias
  , ld_t__range	    type uj0_t_sel
  , ld_t__dim_list  type zbd00_t_ch_key
  , ld_s__dim_list  type zbd00_s_ch_key
  .

  field-symbols
  : <ld_s__attr_list>	type uj_attr_name
  .

  ld_t__alias     = it_alias.
  ld_t__range     = it_range.

  delete ld_t__range where dimension          <> i_dimension.
  delete ld_t__alias where bpc_name-dimension <> i_dimension.

  loop at it_attr_list assigning <ld_s__attr_list>.
    clear ld_s__dim_list.
    if <ld_s__attr_list> = uja00_cs_attr-id.
      ld_s__dim_list-dimension = i_dimension.
    else.
      ld_s__dim_list-dimension = i_dimension.
      ld_s__dim_list-attribute   = <ld_s__attr_list>.
    endif.
    insert ld_s__dim_list into table ld_t__dim_list.
  endloop.

  cd_s__appl_cust-flag = abap_true.
  cd_s__appl_cust-dimension = i_dimension.

*  cd_s__appl_cust-kyf  = it_kyf_list.

  create object e_infocube
    exporting
      i_appset_id = i_appset_id
      i_type_pk   = i_type_pk
      it_alias    = ld_t__alias
      it_range    = ld_t__range
      it_dim_list = ld_t__dim_list.

  clear cd_s__appl_cust.

endmethod.

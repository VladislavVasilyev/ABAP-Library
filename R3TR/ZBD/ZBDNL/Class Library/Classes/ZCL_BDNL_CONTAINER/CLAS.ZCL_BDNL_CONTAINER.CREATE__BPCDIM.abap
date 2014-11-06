method create__bpcdim.

*  break-point.

  data
  : ld_t__attrlist              type uja_t_attr_name
  .

  field-symbols
  : <ld_s__dimlist>             type zbd00_s_ch_key
  .

  if gd_f__init = abap_false.

    loop at gd_s__param-dim_list assigning <ld_s__dimlist>.
      if <ld_s__dimlist>-attribute is initial.
        append uja00_cs_attr-id to ld_t__attrlist.
      else.
        append <ld_s__dimlist>-attribute to ld_t__attrlist.
      endif.
    endloop.

    gr_o__container = zcl_bd00_appl_table=>get_dimension(
                               it_alias     = gd_s__param-alias
                               it_range     = gd_s__param-range
                               i_appset_id  = gd_s__param-appset_id
                               i_dimension  = gd_s__param-dim_name
                               i_type_pk    = gd_s__param-tech_type_table
                               it_attr_list = ld_t__attrlist ).

    gr_o__container->next_pack( zbd0c_read_mode-gendim ).
    gd_f__init = abap_true.
    e_f__create = abap_true.
  else.
    gr_o__container->reset_index( ).
    e_f__create = abap_false.
  endif.

endmethod.

method get_model.

  data
  : ld_s__key_list          like line of gd_t__key_list
  , ld_s__dimension         type line of ty_s_key_list-dimensions
  , ld_t__dim_list          like it_dim_list
  , ld_s__dim_list          like line of it_dim_list
  , ld_s__tech_dim          type zbd00_s_dimn
  , ld_s__tech_alias        type ty_s_alias
  , ld_s__bpc_alias         type zbd00_s_alias
  .

  field-symbols
  : <lt_tech_dim>           type zbd00_t_dimn
  , <gt_key>                like gd_t__key_list
  , <gs_key>                like line of gd_t__key_list
  , <ls_dim_list>           like line of it_dim_list
  , <ls_t_ch_key>           type zbd00_s_ch_key
  , <ld_s__appl_alias>      type zbd00_s_alias
  , <ld_s__component>       type line of abap_keydescr_tab
  .

  create object e_obj
    exporting
      i_appset_id = i_appset_id
      i_appl_id   = i_appl_id.

  break-point id zbd00.

  assign
  : e_obj->gr_o__application->gd_t__dimensions to <lt_tech_dim>
  , e_obj->gd_t__key_list                      to <gt_key>
  .

  e_obj->gd_t__dim_list = it_dim_list.

*╔═══════════════════════════════════════════════════════════════════╗
*║ Список полей по умолчанию                                         ║
*╠═══════════════════════════════════════════════════════════════════╣
  loop at <lt_tech_dim>
    into ld_s__tech_dim .

    if it_dim_list is not supplied or it_dim_list is initial.
      check ld_s__tech_dim-type = zcl_bd00_application=>cs_dm or
            ld_s__tech_dim-type = zcl_bd00_application=>cs_kf.
    else.
      if ld_s__tech_dim-type = zcl_bd00_application=>cs_kf.
      else.
        read table it_dim_list
             with table key dimension = ld_s__tech_dim-dimension
                            attribute = ld_s__tech_dim-attribute
             into ld_s__dim_list.

        check sy-subrc = 0.
      endif.
    endif.

    if it_dim_list is not initial and it_alias is not initial.
      read table it_alias
           with table key bpc_name-dimension = ld_s__tech_dim-dimension
                          bpc_name-attribute = ld_s__tech_dim-attribute
           assigning <ld_s__appl_alias>.

      if sy-subrc = 0.
        ld_s__tech_alias-tech_name = ld_s__tech_dim-tech_name.
        ld_s__bpc_alias-bpc_name-dimension = ld_s__tech_dim-dimension.
        ld_s__bpc_alias-bpc_name-attribute = ld_s__tech_dim-attribute.

        read table <lt_tech_dim>
             with table key dimension = <ld_s__appl_alias>-bpc_alias-dimension
                            attribute = <ld_s__appl_alias>-bpc_alias-attribute
             into ld_s__tech_dim.

        ld_s__tech_alias-tech_alias = ld_s__tech_dim-tech_alias.
        ld_s__bpc_alias-bpc_alias-dimension = ld_s__tech_dim-dimension.
        ld_s__bpc_alias-bpc_alias-attribute = ld_s__tech_dim-attribute.

        insert ld_s__tech_alias into table e_obj->gd_t__tech_alias.
        insert ld_s__bpc_alias into table  e_obj->gd_t__bpc_alias.
      endif.
    endif.

    move-corresponding ld_s__tech_dim to ld_s__dim_list.

    insert ld_s__dim_list into table ld_t__dim_list.
    clear ld_s__dim_list.
  endloop.
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Insert PK                                                         ║
*╠═══════════════════════════════════════════════════════════════════╣
  ld_s__key_list-nkey = cs_pk.
  ld_s__key_list-type = e_obj->gd_v__type_pk = i_type_pk.

  insert ld_s__key_list into table <gt_key> assigning <gs_key>.

  loop at ld_t__dim_list
       assigning <ls_t_ch_key>.

    read table <lt_tech_dim>
         with table key dimension = <ls_t_ch_key>-dimension
                        attribute = <ls_t_ch_key>-attribute
         into           ld_s__tech_dim.

    check sy-subrc = 0.

    move-corresponding
        : <ls_t_ch_key> to ld_s__dimension
        , ld_s__tech_dim to ld_s__dimension.

    ld_s__dimension-ty_elem ?= cl_abap_datadescr=>describe_by_name( ld_s__tech_dim-dtelnm ).

    insert ld_s__dimension into table <gs_key>-dimensions.
  endloop.
  " проверка измерений
  e_obj->gd_f__write_on = abap_true.

  loop at <lt_tech_dim>
       into ld_s__tech_dim.

    read table <gs_key>-dimensions
         with key tech_alias = ld_s__tech_dim-tech_alias
         transporting no fields.

    case ld_s__tech_dim-type.
      when zcl_bd00_application=>cs_an.
        if sy-subrc eq 0.
          e_obj->gd_f__write_on = abap_false.
          exit.
        endif.
      when zcl_bd00_application=>cs_dm.
        if sy-subrc ne 0.
          e_obj->gd_f__write_on = abap_false.
          exit.
        endif.
      when zcl_bd00_application=>cs_kf.
    endcase.

  endloop.
*╚═══════════════════════════════════════════════════════════════════╝

  get reference of <gs_key>-dimensions into e_obj->gr_t__dimension .

  e_obj->create_line( ).
  e_obj->create_table( ).
  e_obj->create_sfc( ).
  e_obj->create_sfk( ).

  e_obj->gd_f__complete_key = abap_true.

  loop at e_obj->gd_t__components
    assigning <ld_s__component>
       where table_line <> e_obj->gd_v__signeddata.

    read table e_obj->gd_s__handle-tab-tech_name->key
         with key table_line = <ld_s__component>
         transporting no fields.

    check sy-subrc <> 0.
    e_obj->gd_f__complete_key = abap_false.
    exit.
  endloop.

endmethod.

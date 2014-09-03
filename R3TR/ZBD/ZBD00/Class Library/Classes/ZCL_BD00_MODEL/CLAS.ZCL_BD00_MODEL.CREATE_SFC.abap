method create_sfc.

  data
  : ls_sfc          type rsdri_s_sfc
  .

  field-symbols
  : <gs_key>        type zcl_bd00_model=>ty_s_key_list
  , <ls_dimensions> type zcl_bd00_model=>ty_s_dim_list
  , <ld_s__appl_alias>  type ty_s_alias
  .

  read table gd_t__key_list
       with table key nkey = zcl_bd00_model=>cs_pk
       assigning <gs_key>.

  loop at <gs_key>-dimensions
     assigning <ls_dimensions>
     where type = zcl_bd00_application=>cs_an or
           type = zcl_bd00_application=>cs_dm.

    read table gd_t__tech_alias
         with table key tech_alias = <ls_dimensions>-tech_alias
         assigning <ld_s__appl_alias>.

    if sy-subrc = 0.
      ls_sfc-chanm    = <ld_s__appl_alias>-tech_name.
      ls_sfc-chaalias = <ld_s__appl_alias>-tech_alias.

    else.
      ls_sfc-chanm    = <ls_dimensions>-tech_name.
      ls_sfc-chaalias = <ls_dimensions>-tech_alias.
    endif.

    ls_sfc-orderby  = <ls_dimensions>-orderby.
    insert ls_sfc into table gd_t__sfc.
  endloop.

  sort gd_t__sfc by orderby ascending.
endmethod.

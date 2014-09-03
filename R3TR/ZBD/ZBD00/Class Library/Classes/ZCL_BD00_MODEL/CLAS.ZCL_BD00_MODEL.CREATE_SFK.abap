method CREATE_SFK.

  data
      : ls_sfk          type rsdri_s_sfk
      .

 field-symbols
      : <gs_key>        type zcl_bd00_model=>ty_s_key_list
      , <ls_dimensions> type zcl_bd00_model=>ty_s_dim_list
      .

  read table gd_t__key_list
       with table key nkey = zcl_bd00_model=>cs_pk
       assigning <gs_key>.

    loop at <gs_key>-dimensions
       assigning <ls_dimensions>
       where type   = zcl_bd00_application=>cs_kf.
    ls_sfk-kyfnm = <ls_dimensions>-tech_name.
    gd_v__signeddata = ls_sfk-kyfalias = <ls_dimensions>-tech_alias.
    insert gd_v__signeddata into table gd_t__signeddata.
    ls_sfk-aggr    = 'SUM'.
    insert ls_sfk into table gd_t__sfk.
  endloop.

endmethod.

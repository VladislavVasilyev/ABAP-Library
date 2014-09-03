method create_table.

  types begin of l_ty_s_dim.
  types tech_name    type string.
  types appl_name    type uj_dim_name.
  types orderby type rsrsfsort.
  types end   of l_ty_s_dim.

  data
  : l_line_type	      type ref to cl_abap_datadescr
  , l_table_kind      type abap_tablekind
  , l_unique          type abap_bool
  , lt_key_tech_name  type abap_keydescr_tab
  , lt_key_appl_name  type abap_keydescr_tab
  , l_key_kind        type abap_keydefkind
  , lt_sort_key       type sorted table of l_ty_s_dim with non-unique key orderby
  , ls_sort_key       type l_ty_s_dim
  .

  field-symbols
  : <gs_key>          like line of gd_t__key_list
  , <ls_dimensions>   type ty_s_dim_list
  .

  read table gd_t__key_list index 1 assigning <gs_key>.

  l_line_type = gd_s__handle-st-tech_name.

  loop at <gs_key>-dimensions
       assigning <ls_dimensions>
       where f_key   = abap_true and
             ( type  = zcl_bd00_application=>cs_an or
               type  = zcl_bd00_application=>cs_dm ).

    ls_sort_key-tech_name = <ls_dimensions>-tech_alias.
    ls_sort_key-orderby = <ls_dimensions>-orderby.

    if gd_f__write_on = abap_true.
      ls_sort_key-appl_name = <ls_dimensions>-dimension.
    endif.

    insert ls_sort_key into table lt_sort_key.
  endloop.

  loop at lt_sort_key
      into ls_sort_key
      where orderby <> 0.
    append ls_sort_key-tech_name to lt_key_tech_name.
    check gd_f__write_on = abap_true.
    append ls_sort_key-appl_name to lt_key_appl_name.
  endloop.

*--------------------------------------------------------------------*
* KEY LIST
*--------------------------------------------------------------------*
  loop at lt_sort_key
    into ls_sort_key
    where orderby = 0.
    append ls_sort_key-tech_name to lt_key_tech_name.
    check gd_f__write_on = abap_true.
    append ls_sort_key-appl_name to lt_key_appl_name.
  endloop.

*--------------------------------------------------------------------*
* TABLE TYPE
*--------------------------------------------------------------------*
  case <gs_key>-type.
    when zbd0c_ty_tab-std_non_unique_dk.
      l_table_kind  = cl_abap_tabledescr=>tablekind_std.
    when zbd0c_ty_tab-srd_non_unique_dk or
         zbd0c_ty_tab-srd_unique_dk     or
         zbd0c_ty_tab-srd_non_unique    or
         zbd0c_ty_tab-srd_unique.
      l_table_kind  = cl_abap_tabledescr=>tablekind_sorted.
    when zbd0c_ty_tab-has_unique_dk     or
         zbd0c_ty_tab-has_unique.
      l_table_kind  = cl_abap_tabledescr=>tablekind_hashed.
  endcase.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* UNIQUE OR NON-UNIQUE
*--------------------------------------------------------------------*
  case <gs_key>-type.
    when zbd0c_ty_tab-std_non_unique_dk or
         zbd0c_ty_tab-srd_non_unique_dk or
         zbd0c_ty_tab-srd_non_unique.
      l_unique  = abap_false.
    when zbd0c_ty_tab-srd_unique_dk or
         zbd0c_ty_tab-srd_unique    or
         zbd0c_ty_tab-has_unique_dk or
         zbd0c_ty_tab-has_unique.
      l_unique  = abap_true.
  endcase.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* DEFAULT KEY or NOT DEFAULT KEY
*--------------------------------------------------------------------*
  case <gs_key>-type.
    when zbd0c_ty_tab-std_non_unique_dk or
         zbd0c_ty_tab-srd_non_unique_dk or
         zbd0c_ty_tab-srd_unique_dk     or
         zbd0c_ty_tab-has_unique_dk.
      l_key_kind  = cl_abap_tabledescr=>keydefkind_default.
      clear lt_key_tech_name.
      clear lt_key_appl_name.
    when zbd0c_ty_tab-srd_non_unique    or
         zbd0c_ty_tab-srd_unique        or
         zbd0c_ty_tab-has_unique        .
      if lt_key_tech_name is initial.
        l_key_kind  = cl_abap_tabledescr=>keydefkind_default.
*        l_key_kind  = cl_abap_tabledescr=>keydefkind_tableline.
      else.
        l_key_kind  = cl_abap_tabledescr=>keydefkind_user.
      endif.
  endcase.
*--------------------------------------------------------------------*


  gd_s__handle-tab-tech_name = cl_abap_tabledescr=>create( p_line_type  = gd_s__handle-st-tech_name
                                                        p_unique     = l_unique
                                                        p_table_kind = l_table_kind
                                                        p_key        = lt_key_tech_name
                                                        p_key_kind   = l_key_kind ).

  gd_t__key = gd_s__handle-tab-tech_name->key.

  check gd_f__write_on = abap_true.

  gd_s__handle-tab-appl_name = cl_abap_tabledescr=>create( p_line_type  = gd_s__handle-st-appl_name
                                                        p_unique     = l_unique
                                                        p_table_kind = l_table_kind
                                                        p_key        = lt_key_appl_name
                                                        p_key_kind   = l_key_kind ).
endmethod.

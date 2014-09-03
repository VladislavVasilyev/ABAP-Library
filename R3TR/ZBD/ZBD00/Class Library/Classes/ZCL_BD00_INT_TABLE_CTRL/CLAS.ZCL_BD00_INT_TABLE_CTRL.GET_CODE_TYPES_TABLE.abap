method GET_CODE_TYPES_TABLE.
  constants
      : tabl type string value `types <n> type <t> table of <y> with <u> <d> <k>.`
      .

  data
      : ls_code     type string
      , lo_eldescr  type ref to cl_abap_elemdescr
      , lv_length   type c length 2
      , lv_decimals type c length 2
      , lv_key      type string
      , lv_name     type string
      .

  field-symbols
      : <ls_key> type zcl_bd00_model=>ty_s_key_list
      , <ls_dimension> type zcl_bd00_model=>ty_s_dim_list
      , <lv_key> type abap_keydescr
      .

  refresh code.

  ls_code = tabl.
  replace `<n>` into ls_code with name.
  replace `<y>` into ls_code with name_ty.

  case io_model->gd_s__handle-tab-tech_name->table_kind.
    when cl_abap_tabledescr=>tablekind_std.
      replace `<t>` into ls_code with `standard` .
    when cl_abap_tabledescr=>tablekind_sorted.
      replace `<t>` into ls_code with `sorted` .
    when cl_abap_tabledescr=>tablekind_hashed.
      replace `<t>` into ls_code with `hashed` .
  endcase.

  if io_model->gd_s__handle-tab-tech_name->has_unique_key = abap_true.
    replace `<u>` into ls_code with `unique`.
  else.
    replace `<u>` into ls_code with `non-unique`.
  endif.

  if io_model->gd_s__handle-tab-tech_name->key_defkind = cl_abap_tabledescr=>keydefkind_default.
    replace `<d>` into ls_code with `default key`.
    replace `<k>` into ls_code with ``.
  else.
    replace `<d>` into ls_code with ``.
    lv_key = `key`.
    loop at io_model->gd_s__handle-tab-tech_name->key
        assigning <lv_key>.

      concatenate lv_key ` ` <lv_key> into lv_key.

    endloop.
    replace `<k>` into ls_code with lv_key .
  endif.

  append ls_code to code.
endmethod.

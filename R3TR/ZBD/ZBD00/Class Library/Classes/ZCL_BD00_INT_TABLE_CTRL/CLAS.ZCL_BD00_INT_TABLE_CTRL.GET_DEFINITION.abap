method get_definition.

  data
  : ls_definition      type ty_s_definition
  , l_st_type          type string
  , l_v_type           type string
  , l_tab_type         type string
  , l_string           type string
  , l_st_field_symbol  type string
  , l_st_cfield_symbol  type string
  , l_v_field_symbol   type string
  , l_tab_field_symbol type string
  .

  if io_model is bound.
*   type st
    ls_definition-id = id_code-type.

    concatenate `ty_s_` i_index into ls_definition-name.
    l_st_type = ls_definition-name.

    get_code_types_struct( exporting io_model = io_model
                                     name     = ls_definition-name
                           importing code     = ls_definition-code ).

    insert ls_definition into table et_definition .
    clear ls_definition-code.

*   type tab
    ls_definition-id = id_code-type_tab.
    concatenate `ty_t_` i_index into ls_definition-name.
    l_tab_type = ls_definition-name.


    get_code_types_table(  exporting name     = ls_definition-name
                                     io_model = io_model
                                     name_ty  = l_st_type
                           importing code     = ls_definition-code ).

    insert ls_definition into table et_definition .
    clear ls_definition-code.

*   data tab
    ls_definition-id   = id_code-data_st.
    concatenate
    :`gd_s__` i_index                                           into ls_definition-name
    ,`data ` ls_definition-name ` type ` l_st_type `.`          into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

    ls_definition-id   = id_code-data_tab.
    concatenate
    :`gd_t__` i_index                                           into ls_definition-name
    ,`data ` ls_definition-name ` type ` l_tab_type `.`         into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition .
    clear ls_definition-code.

* ref
    ls_definition-id   = id_code-ref_st.
    concatenate
    :`gr_s__` i_index                                           into ls_definition-name
    ,`data ` ls_definition-name ` type ref to ` l_st_type `.`  into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition .
    clear ls_definition-code.

    ls_definition-id   = id_code-ref_tab.
    concatenate
    :`gr_t__` i_index                                           into ls_definition-name
    ,`data ` ls_definition-name ` type ref to ` l_tab_type `.` into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition .
    clear ls_definition-code.

* field-symbols
    ls_definition-id   = id_code-field_st.
    concatenate
    : `<ld_s__` i_index `>`                                       into ls_definition-name
    , `field-symbols ` ls_definition-name ` type ` l_st_type `.` into l_string.
    l_st_field_symbol = ls_definition-name.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

    ls_definition-id   = id_code-field_cst.
    concatenate
    : `<ld_s_c` i_index `>`                                       into ls_definition-name
    , `field-symbols ` ls_definition-name ` type ` l_st_type `.` into l_string.
    l_st_cfield_symbol = ls_definition-name.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

    ls_definition-id   = id_code-field_tab.
    concatenate
    : `<ld_t__` i_index `>`                                        into ls_definition-name
    , `field-symbols ` ls_definition-name ` type ` l_tab_type `.` into l_string.
    l_tab_field_symbol = ls_definition-name.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

    ls_definition-id   = id_code-global_reference.
    concatenate
    :`gr_o__` i_index                                               into ls_definition-name
    ,`data ` ls_definition-name ` type ref to zcl_bd00_appl_ctrl.` into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

* assign
    ls_definition-id   = id_code-assign_st.
    concatenate
    :`gr_o__`   i_index                                                            into ls_definition-name
    ,`assign ` ls_definition-name `->gr_o__line->line->* to `  l_st_field_symbol `.` into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

    ls_definition-id   = id_code-assign_cst.
    concatenate
    :`gr_o__`   i_index                                                            into ls_definition-name
    ,`assign ` ls_definition-name `->gr_o__line->cline->* to `  l_st_cfield_symbol `.` into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.


    ls_definition-id   = id_code-assign_tab.
    concatenate
    :`gr_o__`     i_index                                               into ls_definition-name
    ,`assign ` ls_definition-name `->gr_o__table->gr_t__table->* to `  l_tab_field_symbol `.` into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

* reference name
    ls_definition-id   = id_code-ref_line.
    concatenate
    : `gr_o__`     i_index                                               into ls_definition-name
    , ls_definition-name `->gr_o__line->line`   into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.




*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
  elseif ir_data is bound.
    data
    : lo_elemdescr type ref to cl_abap_elemdescr
    , lv_length    type string
    .

* types
    concatenate `ty_v_` i_index into ls_definition-name.
    ls_definition-id = id_code-type.

    l_v_type = ls_definition-name.
    lo_elemdescr ?= cl_abap_elemdescr=>describe_by_data_ref( p_data_ref = ir_data ).
    lv_length     = lo_elemdescr->output_length.

    if lo_elemdescr->help_id is initial.
      case lo_elemdescr->type_kind.
        when cl_abap_elemdescr=>typekind_char.
          concatenate `types ` ls_definition-name ` type c leght ` lv_length `.` into l_string.
        when cl_abap_elemdescr=>typekind_string.
          concatenate `types ` ls_definition-name ` type string. ` into l_string.
        when cl_abap_elemdescr=>typekind_int.
          concatenate `types ` ls_definition-name ` type i. ` into l_string.
      endcase.
    else.
      concatenate `types ` ls_definition-name ` type ` lo_elemdescr->help_id `.` into l_string.
    endif.

    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear  ls_definition-code.

* data
    ls_definition-id   = id_code-data_st.
    concatenate
    :`gd_v__` i_index                                           into ls_definition-name
    ,`data ` ls_definition-name ` type ` l_v_type `.`       into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

* ref
    ls_definition-id   = id_code-global_reference.
    concatenate
    :`gr_v__`  i_index                                           into ls_definition-name
    ,`data ` ls_definition-name ` type ref to ` l_v_type `.`  into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition .
    clear ls_definition-code.

* field-symbol
    ls_definition-id   = id_code-field_st.
    concatenate
    : `<ld_v__` i_index `>`                                         into ls_definition-name
    , `field-symbols ` ls_definition-name ` type ` l_v_type `.` into l_string.
    l_v_field_symbol = ls_definition-name.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.

* assign
    ls_definition-id   = id_code-assign_st.
    concatenate
    :`gr_v__`     i_index                                               into ls_definition-name
    ,`assign ` ls_definition-name `->* to `  l_v_field_symbol `.` into l_string.
    append l_string to ls_definition-code.
    insert ls_definition into table et_definition.
    clear ls_definition-code.
  endif.
endmethod.

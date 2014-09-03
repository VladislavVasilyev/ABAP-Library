method GET_MBR_DATA.
*--------------------------------------------------------------------*
* E_DATA возвращает ссылку на BPC измерение
*--------------------------------------------------------------------*
  data
      : lo_mbr_data       type ref to cl_uja_dim
      , lr_std_data       type ref to data
      , lr_s_data         type ref to data
      , lr_ht_data        type ref to data
      , lr_s_descr_data   type ref to cl_abap_structdescr
      , lr_t_descr_data   type ref to cl_abap_tabledescr
      , lt_key            type abap_keydescr_tab
      , lr_data           type ref to data
      , ls_components     type line of abap_compdescr_tab
      .

  field-symbols
      : <ls_dim_list> type ty_s_dim_list
      , <lt_hash>     type hashed table
      , <lt_data>     type standard table
      , <any_table>   type any table
      .

  create object lo_mbr_data
    exporting
      i_appset_id = i_appset_id
      i_dimension = i_dim_name.

  lo_mbr_data->read_mbr_data(
        exporting it_attr_list  = it_attr_list
                  it_sel        = it_sel
                  it_sel_mbr    = it_sel_mbr
        importing er_data       = lr_std_data ).

  assign lr_std_data->* to <lt_data>.

  sort <lt_data> ascending by (uja00_cs_attr-id).

  create data lr_s_data like line of <lt_data>.
  lr_s_descr_data ?= cl_abap_structdescr=>describe_by_data_ref( lr_s_data ).
  lr_t_descr_data ?= cl_abap_tabledescr=>describe_by_data_ref( lr_std_data ).

  lr_data = lr_std_data.

  if if_ht = abap_true. " копировать в хэш таблицу
    free lr_t_descr_data.

    append uja00_cs_attr-id to lt_key.


    lr_t_descr_data = cl_abap_tabledescr=>create(
                        p_line_type   = lr_s_descr_data
                        p_unique      = abap_true
                        p_table_kind  = cl_abap_tabledescr=>tablekind_hashed
                        p_key         = lt_key ).

    create data lr_ht_data type handle lr_t_descr_data.
    assign lr_ht_data->*  to <lt_hash>.
    insert lines of <lt_data> into table <lt_hash>.

    clear <lt_data>. free: lr_data, lr_std_data.
    lr_data = lr_ht_data.
  endif.

  e_data-tab = lr_data.
  create data e_data-st-ref type handle lr_s_descr_data.

  e_data-cl-st ?= lr_s_descr_data.
  e_data-cl-tb ?= lr_t_descr_data.
  e_data-cp-key = lt_key.

  loop at lr_s_descr_data->components
    into ls_components.
    append ls_components-name to e_data-cp-dim.
  endloop.

endmethod.

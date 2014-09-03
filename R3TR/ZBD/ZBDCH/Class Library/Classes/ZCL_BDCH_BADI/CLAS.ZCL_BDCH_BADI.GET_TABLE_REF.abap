method GET_TABLE_REF.
  data
    : lo_model                type ref to if_uj_model
    , lo_appl_rate            type ref to if_uja_application_data
    , lt_dim_name             type uja_t_dim_list
    , ls_dim_name             type line of uja_t_dim_list
    , ls_dim_name_save        type uja_t_dim_list
    , lr_data                 type ref to data
    , lr_s_data               type ref to data
    , lr_s_descr_data         type ref to cl_abap_structdescr
    , lr_t_descr_data         type ref to cl_abap_tabledescr
    , lt_key                  type abap_keydescr_tab
    , ls_key                  type line of abap_keydescr_tab
    .

  FIELD-SYMBOLS
    : <lt_data>               type standard table
    , <any>                   type any
    .

  lo_model     = cl_uj_model=>get_model( i_appset_id ).
  lo_appl_rate = lo_model->get_appl_data( i_appl_id ).

  lo_appl_rate->get_dim_list(
    exporting if_inc_measure = abap_true
    importing et_dim_name    = lt_dim_name ).


  if it_dim_field is supplied and
     it_dim_field is not initial.
    ls_dim_name_save = lt_dim_name.
    loop at lt_dim_name
      into  ls_dim_name.
      read table it_dim_field
        with key table_line = ls_dim_name
        transporting no fields.
      check sy-subrc <> 0.
      delete lt_dim_name.
    endloop.

    if lt_dim_name is initial.
      lt_dim_name = ls_dim_name_save.
    endif.
  endif.

*    try.
  lo_model->create_tx_data_ref(
    exporting i_appl_name = i_appl_id
      i_type      = 'T'
      it_dim_name = lt_dim_name
    importing er_data = lr_data ).

  assign lr_data->* to <lt_data>.

  if it_key_field is supplied and
     it_key_field is not initial.
    loop at it_key_field
      into ls_key.
      read table lt_dim_name
        with key table_line = ls_key
        transporting no fields .
      check sy-subrc = 0.
      append ls_key to lt_key.
    endloop.
  else.
    loop at lt_dim_name
    into ls_dim_name.
      append ls_dim_name to lt_key.
    endloop.
  endif.

  create data lr_s_data like  line of <lt_data>.
  lr_s_descr_data ?= cl_abap_structdescr=>describe_by_data_ref( lr_s_data ).

  case i_type.
    when cl_abap_tabledescr=>tablekind_std.
      lr_t_descr_data = cl_abap_tabledescr=>create(
          p_line_type = lr_s_descr_data ).
    when cl_abap_tabledescr=>tablekind_hashed.
      lr_t_descr_data = cl_abap_tabledescr=>create(
          p_line_type = lr_s_descr_data
          p_unique = abap_true
          p_table_kind = i_type
          p_key = lt_key ).
    when cl_abap_tabledescr=>tablekind_sorted.
      lr_t_descr_data = cl_abap_tabledescr=>create(
          p_line_type = lr_s_descr_data
          p_unique = abap_true
          p_table_kind = i_type
          p_key = lt_key ).
  endcase.

  create data e_ref-tab    type handle lr_t_descr_data.
  create data e_ref-st-ref type handle lr_s_descr_data.
  e_ref-appset_id = i_appset_id.
  e_ref-appl_id = i_appl_id.
  e_ref-cl-tb     = lr_t_descr_data.
  e_ref-cl-st     = lr_s_descr_data.
  e_ref-cp-dim    = lt_dim_name.
  e_ref-cp-key    = lt_key.

endmethod.

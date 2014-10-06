method upload.

  data
  : uxml    type ref to zcl_excel_xml_upload
  , ld_t__worksheets          type zvcst_t__source
  , ld_s__worksheet           type zvcst_s__xmlworksheet
  , ld_t__worksheet           type zvcst_t__xmlworksheet
  , ld_v__file_name           type string
  , ld_v__dimension           type uj_dim_name
  , lr_o__admin_mgr           type ref to cl_uja_admin_mgr
  , it_dim_list               type uja_t_dim_name

  .

  field-symbols
  : <ld_s__worksheet>     type zvcst_s__xmlworksheet
  .

      create object lr_o__admin_mgr
        exporting
          i_appset_id = gd_v__appset_id.

*  ld_v__file_name = gd_v__dimension.

  create object uxml.
  call method uxml->upload_from_serv
    exporting
      i_appset_id = gd_v__appset_id
      i_appl_id   = gd_v__appl_id
      i_file_name = ld_v__file_name
      i_folder    = `DIMENSIONS`
      i_user_id   = gr_i__context->ds_user.

  ld_t__worksheets = uxml->get_worksheets( ).

  loop at ld_t__worksheets into ld_s__worksheet-name.
    append ld_s__worksheet to ld_t__worksheet.
  endloop.

  call method uxml->print_workbook
    changing
      i_t__worksheet = ld_t__worksheet.

  data ld_s__user_def_for_mod type uja_user_def.
  data ld_t__user_def         type uja_user_def.


  loop at ld_t__worksheet assigning <ld_s__worksheet>.
    ld_v__dimension = <ld_s__worksheet>-name.

    " lock dimensions
    call method lr_o__admin_mgr->update_dim_file_lock
      exporting
        i_lock          = abap_true
        i_dimension	=
        ld_v__dimension
      importing
        e_success	=
        ef_success.

    call function 'DB_COMMIT'.

    append ld_v__dimension to  it_dim_list.

    call function 'ZFM_ZVCS_MERGE_CSV'
      exporting
        i_appset_id = gd_v__appset_id
        i_dimension = ld_v__dimension
        i_data      = <ld_s__worksheet>-table.
  endloop.

  call function 'DB_COMMIT'.

  if it_dim_list is not initial.
    call method lr_o__admin_mgr->process_dimension
      exporting
        it_dim_list = it_dim_list
      importing
        et_message  = et_message
        e_success   = ef_success.
  endif.

  " unlock dimensions
  loop at it_dim_list into ld_v__dimension.
    call method lr_o__admin_mgr->update_dim_file_lock
      exporting
        i_lock          = abap_false
        i_dimension	=
        ld_v__dimension
      importing
        e_success	=
        ef_success.
  endloop.

  call function 'DB_COMMIT'.

endmethod.

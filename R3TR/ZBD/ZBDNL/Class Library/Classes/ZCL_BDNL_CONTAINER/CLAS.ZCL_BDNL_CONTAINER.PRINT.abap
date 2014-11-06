method print.

  data
  : xml                           type ref to zcl_excel_xml_download
  , tworksheet                    type zvcst_t__xmlworksheet
  , sworksheet                    type zvcst_s__xmlworksheet
  , ld_s__rename                  type zvcst_s__rename
  , folder                        type string
*  , script                        type string
  .

  field-symbols
  : <gd_t__dimension>             type zcl_bd00_model=>ty_t_dim_list
  , <gd_s__dimension>             type zcl_bd00_model=>ty_s_dim_list
  .

  free xml.

  clear
  : tworksheet
  , sworksheet
  .

  create object xml.

*  break-point.

  sworksheet-name                 = gd_v__tablename.
  sworksheet-table                = gr_o__container->get_ref_table( ).

  "rename
  assign gr_o__container->gr_o__model->gr_t__dimension->* to <gd_t__dimension>.

  loop at <gd_t__dimension> assigning <gd_s__dimension>.
    ld_s__rename-field = <gd_s__dimension>-tech_alias.

    ld_s__rename-name = <gd_s__dimension>-dimension.

    if <gd_s__dimension>-attribute is not initial.
      concatenate ld_s__rename-name `.` <gd_s__dimension>-attribute into ld_s__rename-name.
    endif.

    insert ld_s__rename into table sworksheet-rename.

  endloop.

  sworksheet-f__filter            = abap_true.
  sworksheet-f__validtextlength   = abap_true.
  sworksheet-f__splitvertical     = abap_false.

  append sworksheet to tworksheet.

  sworksheet-name = 'RANGE'.
  sworksheet-table = gr_o__container->get_ref_range_table( ).
  append sworksheet to tworksheet.

  xml->create_xml_workbook( tworksheet ).

*  script = gd_v__script.
*  replace `.LGF` in script with space.

  concatenate `TABLES\` cd_v__short_script into folder.

  call method xml->download_on_bpc
    exporting
      i_appset_id = zcl_bd00_context=>gv_appset_id
      i_appl_id   = zcl_bd00_context=>gv_appl_id
      i_file_name = gd_v__tablename
      i_folder    = folder
      i_user_id   = zcl_bd00_context=>gd_s__user_id.

endmethod.

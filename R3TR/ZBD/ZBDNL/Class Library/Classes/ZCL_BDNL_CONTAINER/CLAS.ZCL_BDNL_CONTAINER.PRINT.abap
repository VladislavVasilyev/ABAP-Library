method print.

  data xml type ref to zcl_excel_xml_download.
  data tworksheet type zvcst_t__xmlworksheet.
  data sworksheet type zvcst_s__xmlworksheet.
  data folder type string.
  data script type string.

  free xml.
  clear
  : tworksheet
  , sworksheet
  .

  create object xml.

  sworksheet-name = gd_v__tablename.
  sworksheet-table = gr_o__container->get_ref_table( ).

  sworksheet-f__filter            = abap_true.
  sworksheet-f__validtextlength   = abap_true.
  sworksheet-f__splitvertical     = abap_true.

  append sworksheet to tworksheet.


  xml->create_xml_workbook( tworksheet ).

  script = gd_v__script.
  replace `.LGF` in script with space.

  concatenate `TABLES\` CD_V__short_SCRIPT into folder.

  call method xml->download_on_bpc
    exporting
      i_appset_id = zcl_bd00_context=>gv_appset_id
      i_appl_id   = zcl_bd00_context=>gv_appl_id
      i_file_name = gd_v__tablename
      i_folder    = folder
      i_user_id   = zcl_bd00_context=>gd_s__user_id.

endmethod.

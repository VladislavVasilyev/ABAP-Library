method constructor.

  data
  : retcode           type sy-subrc
  , ld_v__xmlfilename type string
  , l_size            type i
  , lt_data           type swxmlcont
  .

  field-symbols
  : <filename>        type zvcst_s__char255
  .

  check i_v__filename-type = zvcsc_filetype-xml.

* read xml
  create object gr_o__xmldoc.
  gd_v__filename = i_v__filename.
  concatenate i_v__filename-path i_v__filename-name `.` i_v__filename-type into ld_v__xmlfilename.


  call method cl_gui_frontend_services=>gui_upload
     exporting
       filename                = ld_v__xmlfilename
       filetype                = 'BIN'
*      HAS_FIELD_SEPARATOR     = SPACE
*      HEADER_LENGTH           = 0
     importing
       filelength              = l_size
*      HEADER                  =
     changing
       data_tab                = lt_data
     exceptions
       file_open_error         = 2
       file_read_error         = 3
       invalid_type            = 4
       no_batch                = 5
       gui_refuse_filetransfer = 7
       others                  = 99.


  retcode = gr_o__xmldoc->create_with_table( table = lt_data size = l_size ).

  call method add_txtsource( ).
  gd_v__object = xmlsearchobject( gr_o__xmldoc->m_document ).

endmethod.

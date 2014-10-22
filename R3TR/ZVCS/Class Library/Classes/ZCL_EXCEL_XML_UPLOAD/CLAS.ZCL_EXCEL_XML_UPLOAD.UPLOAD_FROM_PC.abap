method UPLOAD_FROM_PC.

  data
  : retcode                 type sy-subrc
  , ld_v__xmlfilename       type string
  , l_size                  type i
  , lt_data                 type swxmlcont
  , gr_o__xmldoc            type ref to cl_xml_document
  , lr_i__streamfactory     type ref to if_ixml_stream_factory
  , lr_i__istream           type ref to if_ixml_istream
  , lr_i__parser                 type ref to if_ixml_parser
  .

  field-symbols
  : <filename>              type zvcst_s__char255
  .

  gd_f__first_header = first_header.

  " create xml factory
  call method cl_gui_frontend_services=>gui_upload
     exporting
       filename                = PATH "ld_v__xmlfilename
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

  lr_i__streamfactory = gd_i__ixml->create_stream_factory( ).
  lr_i__istream = lr_i__streamfactory->create_istream_itable( table = lt_data size  = l_size ).
  lr_i__parser = gd_i__ixml->create_parser( stream_factory = lr_i__streamfactory
                                          istream        = lr_i__istream
                                            document       = gd_i__document ).

  lr_i__parser->parse( ).

  call method lr_i__istream->close( ).
  clear lr_i__istream.

  find_worksheets( ).
*  print_table( ).

endmethod.

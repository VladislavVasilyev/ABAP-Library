method upload_from_serv.

  types
  : begin of xml_line
    , data(256) type x
    , end of xml_line.

  data
  : ld_v__size                  type i
  , gr_o__xmldoc                type ref to cl_xml_document
  , lr_i__streamfactory         type ref to if_ixml_stream_factory
  , lr_i__istream               type ref to if_ixml_istream
  , lr_i__parser                type ref to if_ixml_parser
  , ld_v__docname               type ujf_doc-docname
  , ld_t__content               type ujf_t_recline
  , ld_s__content               type line of ujf_t_recline
  , ld_v__buf                   type string
  , ld_v__xstring               type xstring
  , ld_f__eod                   type rs_bool
  , ld_t__xml_table             type table of xml_line
  .

  field-symbols
  : <filename>                  type zvcst_s__char255
  .

  gd_f__first_header = first_header.

  concatenate `\ROOT\WEBFOLDERS\` i_appset_id `\` i_appl_id `\` `DATAMANAGER\DATAFILES\` i_folder  `\` i_file_name `.XML` into    ld_v__docname.

  break-point.

  data lr_o__filemng type ref to cl_ujf_file_service_mgr.

  call method cl_ujf_file_service_mgr=>factory
    exporting
      is_user   = i_user_id
      i_appset  = i_appset_id
    receiving
      r_manager = lr_o__filemng.

*try.
  do.
    clear ld_t__content.

    call method lr_o__filemng->get_document_data_mgr
      exporting
        i_docname      = ld_v__docname
        i_package_size = 1000
*    i_preview      = ABAP_FALSE
*    i_reset_cursor = ABAP_FALSE
*    i_ftp_user     = 'anonymous'
*    i_ftp_password = SPACE
      importing
        et_data_table  = ld_t__content
        e_end_of_table = ld_f__eod.
* catch cx_ujf_file_service_error .
*endtry.

    loop at ld_t__content into ld_s__content.
      concatenate ld_v__buf ld_s__content-line into ld_v__buf.
    endloop.
    if ld_f__eod = abap_true.
      exit.
    endif.

  enddo.

  call function 'SCMS_STRING_TO_XSTRING'
    exporting
      text           = ld_v__buf
*     MIMETYPE       = ' '
     encoding       = '1504'
   importing
     buffer         = ld_v__xstring
*   EXCEPTIONS
*     FAILED         = 1
*     OTHERS         = 2
            .

  call function 'SCMS_XSTRING_TO_BINARY'
    exporting
      buffer        = ld_v__xstring
    importing
      output_length = ld_v__size
    tables
      binary_tab    = ld_t__xml_table.

  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.


  " create xml factory
  gd_i__ixml ?= cl_ixml=>create( ).

  " Creating the dom object model
  gd_i__document = gd_i__ixml->create_document( ).

  lr_i__streamfactory = gd_i__ixml->create_stream_factory( ).

  lr_i__istream = lr_i__streamfactory->create_istream_itable( table = ld_t__xml_table size  = ld_v__size ).
  lr_i__parser = gd_i__ixml->create_parser( stream_factory = lr_i__streamfactory
                                            istream        = lr_i__istream
                                            document       = gd_i__document ).

  lr_i__parser->parse( ).

  call method lr_i__istream->close( ).
  clear lr_i__istream.

  find_worksheets( ).

endmethod.

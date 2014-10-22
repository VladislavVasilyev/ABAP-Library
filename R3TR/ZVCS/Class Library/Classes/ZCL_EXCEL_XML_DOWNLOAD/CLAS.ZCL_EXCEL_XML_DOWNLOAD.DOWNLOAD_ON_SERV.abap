method download_on_serv.

  types
  : begin of xml_line
    , data(256) type x
    , end of xml_line.

  data
  : lr_i__streamfactory       type ref to if_ixml_stream_factory
  , lr_i__ostream             type ref to if_ixml_ostream
  , lr_i__renderer            type ref to if_ixml_renderer
  , ld_s__buf                 type ujf_s_recline
  , ld_t__content             type ujf_t_recline "ujf_doc-doc_content
  , ld_t__xml_table           type table of xml_line
  , ld_v__rc                  type i
  , ld_v__xml_size            type i
  , ld_v__docname             type ujf_doc-docname
  .


*   Creating a stream factory
  lr_i__streamfactory = gd_i__ixml->create_stream_factory( ).
*   Connect internal XML table to stream factory
  lr_i__ostream = lr_i__streamfactory->create_ostream_itable( table = ld_t__xml_table ).
*   Rendering the document
  lr_i__ostream->get_pretty_print( ).

  lr_i__renderer = gd_i__ixml->create_renderer( ostream  = lr_i__ostream
                                                document = gd_i__document ).
  ld_v__rc = lr_i__renderer->render( ).

*   Saving the XML document
  ld_v__xml_size = lr_i__ostream->get_num_written_raw( ).



  call function 'SCMS_BINARY_TO_STRING'
    exporting
      input_length       = ld_v__xml_size
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
      encoding = `1504`
   importing
     text_buffer         = ld_s__buf-line
    tables
      binary_tab         = ld_t__xml_table.


  append ld_s__buf to ld_t__content.

  concatenate `\ROOT\WEBFOLDERS\` i_appset_id `\` i_appl_id `\` `DATAMANAGER\DATAFILES\` i_folder  `\` i_file_name `.XML` into    ld_v__docname.

  data lr_o__filemng type ref to cl_ujf_file_service_mgr.

  call method cl_ujf_file_service_mgr=>factory
    exporting
      is_user   = i_user_id
      i_appset  = i_appset_id
    receiving
      r_manager = lr_o__filemng.


*                       try.
  call method lr_o__filemng->put_document_data_mgr
    exporting
      i_docname          = ld_v__docname
      i_append           = abap_false
      i_doc_content      = ld_t__content
*                           i_content_delivery = ABAP_FALSE
      .
*                        catch cx_ujf_file_service_error .
*                       endtry.
*  put_document_data_mgr

endmethod.

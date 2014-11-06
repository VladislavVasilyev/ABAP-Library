method download_on_bpc.

  types
  : begin of xml_line
    , data(256) type x
    , end of xml_line.

  data
  : lr_i__streamfactory       type ref to if_ixml_stream_factory
  , lr_i__ostream             type ref to if_ixml_ostream
  , lr_i__renderer            type ref to if_ixml_renderer
  , ld_v__buf                 type ujf_doc-doc_content
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



  call function 'SCMS_BINARY_TO_XSTRING'
    exporting
      input_length       = ld_v__xml_size
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
*      encoding = `1504`
   importing
     buffer         = ld_v__buf
    tables
      binary_tab         = ld_t__xml_table.



  concatenate `\ROOT\WEBFOLDERS\` i_appset_id `\` i_appl_id `\` `EEXCEL\` i_folder  `\` i_file_name `.XLS` into    ld_v__docname.


  call function 'UJF_API_PUT_DOCUMENT'
    exporting
      i_user                      = i_user_id
      i_appset                    = i_appset_id
      i_docname                   = ld_v__docname
      i_compression               = 'N'
*   I_SPLICE_ZIP                = 'Y'
      i_doc_content               = ld_v__buf
* IMPORTING
*   E_MESSAGE_LINES             =
* EXCEPTIONS
*   SYSTEM_FAILURE              = 1
*   COMMUNICATION_FAILURE       = 2
*   OTHERS                      = 3
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.














*
*
*
*  data lr_o__filemng type ref to cl_ujf_file_service_mgr.
*
*  call method cl_ujf_file_service_mgr=>factory
*    exporting
*      is_user   = i_user_id
*      i_appset  = i_appset_id
*    receiving
*      r_manager = lr_o__filemng.
*
*
**                       try.
*  call method lr_o__filemng->put_document_data_mgr
*    exporting
*      i_docname          = ld_v__docname
*      i_append           = abap_false
*      i_doc_content      = ld_t__content
**                           i_content_delivery = ABAP_FALSE
*      .
**                        catch cx_ujf_file_service_error .
**                       endtry.
**  put_document_data_mgr

endmethod.

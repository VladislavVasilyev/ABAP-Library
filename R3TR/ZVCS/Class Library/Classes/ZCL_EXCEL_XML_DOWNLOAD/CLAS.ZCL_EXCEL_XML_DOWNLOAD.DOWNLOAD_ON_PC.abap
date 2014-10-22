method DOWNLOAD_ON_PC.

  types: begin of xml_line,
        data(256) type x,
       end of xml_line.


  data
  : l_streamfactory   type ref to if_ixml_stream_factory
  , l_ostream         type ref to if_ixml_ostream
  , l_renderer        type ref to if_ixml_renderer
  , l_xml_table       type table of xml_line
  , l_rc              type i
  , l_xml_size        type i
  .

*   Creating a stream factory
  l_streamfactory = gd_i__ixml->create_stream_factory( ).
*   Connect internal XML table to stream factory
  l_ostream = l_streamfactory->create_ostream_itable( table = l_xml_table ).
*   Rendering the document
  l_renderer = gd_i__ixml->create_renderer( ostream  = l_ostream
                                        document = gd_i__document ).
  l_rc = l_renderer->render( ).
*    l_ostream->GET_PRETTY_PRINT( ).

*   Saving the XML document
  l_xml_size = l_ostream->get_num_written_raw( ).

  call method cl_gui_frontend_services=>gui_download
    exporting
      bin_filesize = l_xml_size
      filename     = path
      filetype     = 'BIN'
    changing
      data_tab     = l_xml_table
    exceptions
      others       = 24.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endmethod.

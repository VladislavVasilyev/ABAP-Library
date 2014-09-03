method add_txtsource.

  data
  : lr_i__sourceid type ref to if_ixml_node
  , lr_i__root     type ref to if_ixml_node
  , lr_i__iterator type ref to if_ixml_node_iterator
  , ld_v__sourceid type string
  , ld_i__ptext type ref to if_ixml_text
  , ld_t__source type zvcst_t__source
  , ld_s__source type zvcst_s__source
  , ld_v__source type string
  .

  lr_i__iterator =  gr_o__xmldoc->m_document->if_ixml_node~create_iterator( ).

  do.
    lr_i__sourceid = lr_i__iterator->get_next( ).
    if lr_i__sourceid is initial. exit. endif.

    ld_v__sourceid = lr_i__sourceid->get_name( ).

    case lr_i__sourceid->get_type( ).
      when if_ixml_node=>co_node_element.
        if ld_v__sourceid <> `SOURCEID`.
          lr_i__root     ?= lr_i__sourceid.
        endif.
      when if_ixml_node=>co_node_text.


    endcase.

    check ld_v__sourceid = `SOURCEID`.

    lr_i__sourceid = lr_i__sourceid->get_first_child( ).

    case lr_i__sourceid->get_type( ).
      when if_ixml_node=>co_node_element.

      when if_ixml_node=>co_node_text.
        ld_i__ptext ?= lr_i__sourceid->query_interface( ixml_iid_text ).

        if ld_i__ptext->ws_only( ) is initial.
          ld_v__sourceid = lr_i__sourceid->get_value( ).
          concatenate gd_v__filename-path ld_v__sourceid  into ld_v__sourceid.

          cl_gui_frontend_services=>gui_upload(
          exporting
            filename = ld_v__sourceid
            codepage = `4110`
             filetype = `ASC`
*        write_lf = ``
          changing
            data_tab = ld_t__source
          exceptions
        others   = 24 ).
          lr_i__sourceid->remove_node( ).

          loop at ld_t__source into ld_s__source.
            ld_v__source = ld_s__source.
            gr_o__xmldoc->m_document->create_simple_element(
                  name = 'item'
                  value = ld_v__source
                  parent = lr_i__root ).
          endloop.
        endif.
    endcase.




  enddo.

*  lr_i__node = gr_o__xmldoc->m_document->get_first_child( ).

*  lr_i__idsource = gr_o__xmldoc->m_document->find_from_name( name = `SOURCEID` ).

endmethod.

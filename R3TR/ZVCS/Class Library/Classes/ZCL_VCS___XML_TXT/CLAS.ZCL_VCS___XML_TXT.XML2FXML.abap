method xml2fxml.

  data
  : ld_v__element     type string
  , ld_v__text        type string
  , ld_v__tag         type string
  , ld_i__node        type ref to if_ixml_node
  , ld_i__ptext       type ref to if_ixml_text
  , lr_i__xmlnode     type ref to if_ixml_node
  , ld_v__strtab      type string
  , ld_v__strtab1      type string
  , ld_v__tab         type i
  , ld_v__nodepath    type string
  , ld_s__txtsource   type zvcst_s__file_source
  .

  field-symbols
  : <lgd_s__reparse> like line of gd_t__xmlformatdoc
  .

  if i_i__ixml_node is bound.
    lr_i__xmlnode ?= i_i__ixml_node.
  else.
    lr_i__xmlnode ?= gr_o__xmldoc->m_document.
  endif.
  ld_v__nodepath = gr_o__xmldoc->get_node_path( lr_i__xmlnode ).
  ld_v__tab      = i_v__tabulation.

  case lr_i__xmlnode->get_type( ).
    when if_ixml_node=>co_node_element.
      do ld_v__tab times.
        concatenate ld_v__strtab cl_abap_char_utilities=>horizontal_tab into ld_v__strtab.
      enddo.

      ld_v__element = lr_i__xmlnode->get_name( ).

      concatenate ld_v__strtab `<` ld_v__element `>` into ld_v__tag.
      append ld_v__tag to gd_t__xmlformatdoc assigning <lgd_s__reparse>.
      add 1 to ld_v__tab.

      if ld_v__nodepath in gd_t__sourcenodepath and gd_t__sourcenodepath is not initial.

        if gd_v__mastername is not initial.
          if gd_v__filename is not initial.
            concatenate gd_v__mastername `.` gd_v__filename `.` gd_v__extsrcname into ld_s__txtsource-filename.
          else.
            concatenate gd_v__mastername `.` gd_v__extsrcname                    into ld_s__txtsource-filename.
          endif.
        else.
          concatenate                      gd_v__filename `.` gd_v__extsrcname into ld_s__txtsource-filename.
        endif.

        concatenate
        : ld_v__strtab cl_abap_char_utilities=>horizontal_tab into ld_v__strtab1
        , ld_v__strtab1 `<SOURCEID>` ld_s__txtsource-filename `</SOURCEID>` into ld_v__tag.

        append ld_v__tag to gd_t__xmlformatdoc.
        concatenate ld_v__strtab `</` ld_v__element `>` into ld_v__tag.
        append ld_v__tag to gd_t__xmlformatdoc assigning <lgd_s__reparse>.

        ld_s__txtsource-source = xml2txt( lr_i__xmlnode ).
        append ld_s__txtsource to gd_t__txtsource.
        return.
      endif.

    when if_ixml_node=>co_node_text.
      ld_i__ptext ?= lr_i__xmlnode->query_interface( ixml_iid_text ).

      if ld_i__ptext->ws_only( ) is initial.
        e_v__text = lr_i__xmlnode->get_value( ).
        if ld_v__nodepath in gd_t__sourcenodename and gd_t__sourcenodename is not initial.
          gd_v__filename = e_v__text.
        endif.
        replace all occurrences of
        : `<` in e_v__text with `&lt;`
        , `>` in e_v__text with `&gt;`
        , `&` in e_v__text with `&amp;`
        , `"` in e_v__text with `&quot;`
        , `'` in e_v__text with `&apos;`
        .
      endif.
  endcase.

  ld_i__node ?= lr_i__xmlnode->get_first_child( ).

  while not ld_i__node is initial.
    ld_v__text = xml2fxml( i_i__ixml_node = ld_i__node i_v__tabulation = ld_v__tab ).
    ld_i__node = ld_i__node->get_next( ).
  endwhile.

  if ld_v__text is not initial.
    concatenate <lgd_s__reparse> ld_v__text `</` ld_v__element `>` into <lgd_s__reparse>.
    return.
  endif.

  check ld_v__element is not initial.
  concatenate ld_v__strtab `</` ld_v__element `>` into ld_v__tag.
  append ld_v__tag to gd_t__xmlformatdoc.

endmethod.

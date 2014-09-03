method xmlsearchobject.

  data
 : ld_v__element type string
 , ld_v__text type string
 , ld_v__tag type string
 , ld_i__node type ref to if_ixml_node
 , ld_i__ptext type ref to if_ixml_text
 , ld_v__strtab type string
 , ld_v__tab type i
 , lr_i__xmlnode type ref to if_ixml_node
 , xml_type type i
 , leng type i
 , text type trobjtype
 , iteraror type i
 .

  field-symbols
  : <l> type abap_compdescr
  , <s> TYPE TROBJTYPE
  .

*  field-symbols
*  : <lgd_s__reparse> like line of gd_t__xmlformatdoc
*  .

  if i_i__ixml_node is bound.
    lr_i__xmlnode ?= i_i__ixml_node.
  else.
    lr_i__xmlnode ?= gr_o__xmldoc->m_document.
  endif.

  if lr_i__xmlnode->get_type( ) = if_ixml_node=>co_node_document.
    lr_i__xmlnode ?= lr_i__xmlnode->get_first_child( ).
    if lr_i__xmlnode->get_type( ) = if_ixml_node=>co_node_element.
      e_v__object = lr_i__xmlnode->get_name( ).
    endif.
  endif.

  data s type ref to cl_abap_structdescr.

  s ?= cl_abap_structdescr=>describe_by_data( zvcsc_r3tr_type ).
  leng = lines( s->components ).

  do leng times.
    assign component sy-index of structure zvcsc_r3tr_type to <s>.
        check <s> = e_v__object.
    return.
  enddo.

endmethod.

method XML2TXT.
  data
  : ld_i__rows type ref to if_ixml_node
  , ld_i__text type ref to if_ixml_node
  , ld_v__text  type zvcst_s__source
  , ld_i__ptext type ref to if_ixml_text
  .

  ld_i__rows ?= i_i__ixml_node->get_first_child( ).



  while not ld_i__rows is initial.
    if ld_i__rows->get_type( ) = if_ixml_node=>co_node_element.
      ld_i__text ?= ld_i__rows->get_first_child( ).
    endif.


    if ld_i__text is initial.

      append initial line to e_t__txtsource.

    else.

      if ld_i__text->get_type( ) = if_ixml_node=>co_node_text.
        ld_i__ptext ?= ld_i__text->query_interface( ixml_iid_text ).
        if ld_i__ptext->ws_only( ) is initial.
          ld_v__text = ld_i__text->get_value( ).
          append ld_v__text to e_t__txtsource.
        endif.
      endif.
    endif.
    ld_i__rows = ld_i__rows->get_next( ).
  endwhile.

endmethod.

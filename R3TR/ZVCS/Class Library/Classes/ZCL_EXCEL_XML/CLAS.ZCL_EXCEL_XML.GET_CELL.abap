method get_cell.

  data
  : lr_i__xmlnode     type ref to if_ixml_node
  , lr_i__xmltext     type ref to if_ixml_node
  , ld_i__ptext       type ref to if_ixml_text
  , indent            type i
  .

  lr_i__xmlnode = node->get_first_child( ).
  if lr_i__xmlnode is initial.
    return.
  endif.

  indent  = lr_i__xmlnode->get_height( ) * 2.

  do.
    case lr_i__xmlnode->get_type( ).
      when if_ixml_node=>co_node_element.
        if lr_i__xmlnode->get_name( ) = `Data`.
          lr_i__xmltext ?= lr_i__xmlnode->get_first_child( ).

          if lr_i__xmltext is initial.
            exit.
          endif.

          ld_i__ptext ?= lr_i__xmltext->query_interface( ixml_iid_text ).
          if ld_i__ptext->ws_only( ) is initial.
            value = lr_i__xmltext->get_value( ).
          endif.


        endif.
    endcase.

    lr_i__xmlnode = lr_i__xmlnode->get_next( ).
    if lr_i__xmlnode is initial.
      exit.
    endif.
  enddo.



*  case lr_i__xmlnode->get_type( ).
*    when if_ixml_node=>co_node_element.
*      ld_v__element = lr_i__xmlnode->get_name( ).
*
*    when if_ixml_node=>co_node_text.
*      ld_i__ptext ?= lr_i__xmlnode->query_interface( ixml_iid_text ).
*
*      if ld_i__ptext->ws_only( ) is initial.
*        e_v__text = lr_i__xmlnode->get_value( ).
*      endif.
*  endcase.

*  ld_i__node ?= lr_i__xmlnode->get_first_child( ).
*
*  while not ld_i__node is initial.
*    ld_v__text = print_node( i_i__ixml_node = ld_i__node ). "i_v__tabulation = ld_v__tab ).
*    ld_i__node = ld_i__node->get_next( ).
*  endwhile.




endmethod.

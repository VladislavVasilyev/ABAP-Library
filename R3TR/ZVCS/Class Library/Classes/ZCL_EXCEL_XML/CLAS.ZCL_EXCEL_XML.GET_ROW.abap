method get_row.

  data
  : lr_i__xmlnode     type ref to if_ixml_node
  , ld_s__row         type ty_s__row
  , indent            type i
  , lr_i__attribute   type ref to if_ixml_named_node_map
  , lr_i__attr_node   type ref to if_ixml_node
  .

  field-symbols
  : <ld_s__row>       type ty_s__row
  .

  lr_i__xmlnode = node->get_first_child( ).

  indent  = lr_i__xmlnode->get_height( ) * 2.

  do.
    case lr_i__xmlnode->get_type( ).
      when if_ixml_node=>co_node_element.
        if lr_i__xmlnode->get_name( ) = `Cell`.
          lr_i__attribute = lr_i__xmlnode->get_attributes( ).
          lr_i__attr_node = lr_i__attribute->get_named_item( name = `Index` namespace = `ss` ).

          ld_s__row-value = get_cell( lr_i__xmlnode ).

          if lr_i__attr_node is initial.
            add 1 to ld_s__row-index.
          else.
            ld_s__row-index = lr_i__attr_node->get_value( ).
          endif.

          if ld_s__row-value is not initial.
            if gd_f__first_header = abap_true and gd_f__header_init = abap_true.
              read table gd_t__header
                   with table key index = ld_s__row-index
                   assigning <ld_s__row>.

              ld_s__row-name = <ld_s__row>-value.

            endif.
            insert ld_s__row into table row.
          endif.
        endif.
    endcase.

    lr_i__xmlnode = lr_i__xmlnode->get_next( ).
    if lr_i__xmlnode is initial.
      exit.
    endif.
  enddo.

endmethod.

method find_worksheets.

  data
  : lr_i__xmlnode           type ref to if_ixml_node
  , lr_i__table             type ref to if_ixml_node
  , lr_i__attribute         type ref to if_ixml_named_node_map
  , lr_i__attr_node         type ref to if_ixml_node
  , ld_s__worksheet         type ty_s__worksheet
  .

  field-symbols
  : <ld_s__worksheet>       type ty_t__worksheet
  .

  lr_i__xmlnode ?= gd_i__document->get_first_child( ).

  if lr_i__xmlnode->get_name( ) = `mso-application`.
    lr_i__xmlnode =  lr_i__xmlnode->get_next( ).
  endif.

  if lr_i__xmlnode->get_name( ) = `Workbook`.
    lr_i__xmlnode = lr_i__xmlnode->get_first_child( ).
  endif.

  do.
    lr_i__xmlnode =  lr_i__xmlnode->get_next( ).

    if lr_i__xmlnode is initial.
      exit.
    endif.

    if lr_i__xmlnode->get_type( ) = if_ixml_node=>co_node_element.

      case lr_i__xmlnode->get_name( ).
        when `Worksheet`.
          lr_i__attribute = lr_i__xmlnode->get_attributes( ).
          lr_i__attr_node = lr_i__attribute->get_named_item( name = `Name` namespace = `ss` ).
          lr_i__table = lr_i__xmlnode->get_first_child( ).

          do.
            if lr_i__table->get_type( ) = if_ixml_node=>co_node_element.
              case lr_i__table->get_name( ).
                when `Table`.
                  ld_s__worksheet-node = lr_i__table.
                  ld_s__worksheet-name = lr_i__attr_node->get_value( ).

                  insert ld_s__worksheet into table gd_t__worksheet.
                  exit.
                when others.
                  lr_i__table =  lr_i__table->get_next( ).
                  if lr_i__table is initial.
                    exit.
                  endif.
              endcase.
            endif.
          enddo.

      endcase.
    endif.
  enddo.

endmethod.

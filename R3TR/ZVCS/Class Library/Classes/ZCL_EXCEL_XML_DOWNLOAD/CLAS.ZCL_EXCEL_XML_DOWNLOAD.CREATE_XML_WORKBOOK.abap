method create_xml_workbook.

  data
  : ld_i__element_root          type ref to if_ixml_element
  , ld_i__nsattribute           type ref to if_ixml_attribute
  , ld_i__element_properties    type ref to if_ixml_element
  , ld_v__value                 type string
  .

  field-symbols
  : <ld_s__worksheet>           type zvcst_s__xmlworksheet
  .


  loop at i_t__worksheet assigning <ld_s__worksheet>.
    call method create_worksheet( <ld_s__worksheet> ).
  endloop.

endmethod.

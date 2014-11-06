method create_xml_workbook.

  field-symbols
  : <ld_s__worksheet>           type zvcst_s__xmlworksheet
  .


  loop at i_t__worksheet assigning <ld_s__worksheet>.
    call method create_worksheet( <ld_s__worksheet> ).
  endloop.

endmethod.

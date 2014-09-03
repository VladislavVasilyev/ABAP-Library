method constructor.
  data
  : lr_result type ref to data
  .

  field-symbols
  : <hashed_table> type hashed table
  .

  call method super->constructor
    exporting
      it_rule_link = it_rule_link.

  case it_rule_link-type.
    when method-add.
    when method-search.
    when method-assign.
  endcase.
endmethod.

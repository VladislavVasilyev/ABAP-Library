method __convert_to_range_table.

  data
  : ld_t__param           type table of string
  , lr_s__line            type ref to data
  .

  field-symbols
  : <string>              type string
  , <e>                   type standard table
  , <s>                   type any
  , <elem>                type any
  .


  assign e             to <e>.
  refresh <e>.
  create data lr_s__line  like line of <e>.
  assign lr_s__line->*    to <s>.

  split i01 at `,` into table ld_t__param.

  assign component `SIGN` of structure <s> to <elem>.
  <elem> = i02.

  assign component `OPTION` of structure <s> to <elem>.
  <elem> = i03.

  loop at ld_t__param assigning <string>.
    condense <string> no-gaps.

    assign component `LOW` of structure <s> to <elem>.
    <elem> = <string>.

    append <s> to <e>.

  endloop.

  endmethod.

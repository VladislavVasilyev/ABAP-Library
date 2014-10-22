class ZCL_EXCEL_XML definition
  public
  abstract
  create public .

*"* public components of class ZCL_EXCEL_XML
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools IXML .
  type-pools ZVCST .

  types:
    begin of ty_s__worksheet
           , name type string
           , node type ref to if_ixml_node
           , end of ty_s__worksheet .
  types:
    begin of ty_s__row
      , index type i
      , name  type string
      , value type string
      , end of ty_s__row .
  types:
    ty_t__row type sorted table of ty_s__row with unique key index .
  types:
    ty_t__worksheet type hashed table of ty_s__worksheet with unique key name .

  methods GET_WORKSHEETS
    returning
      value(WORKSHEETS) type ZVCST_T__SOURCE .
  methods CONSTRUCTOR .
  methods PRINT_WORKBOOK
    changing
      !I_T__WORKSHEET type ZVCST_T__XMLWORKSHEET .

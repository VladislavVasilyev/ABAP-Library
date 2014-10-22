*"* protected components of class ZCL_EXCEL_XML
*"* do not include other source files here!!!
protected section.

  data GD_I__IXML type ref to IF_IXML .
  data GR_I__ELEMENT_ROOT type ref to IF_IXML_ELEMENT .
  data GD_I__DOCUMENT type ref to IF_IXML_DOCUMENT .
  data GR_I__STYLES type ref to IF_IXML_ELEMENT .
  data GD_T__WORKSHEET type TY_T__WORKSHEET .
  data GD_F__FIRST_HEADER type RS_BOOL .
  data GD_F__HEADER_INIT type RS_BOOL .
  data GD_T__HEADER type TY_T__ROW .

  methods GET_CELL
    importing
      !NODE type ref to IF_IXML_NODE
    returning
      value(VALUE) type STRING .
  methods GET_ROW
    importing
      !NODE type ref to IF_IXML_NODE
    returning
      value(ROW) type TY_T__ROW .
  methods FIND_WORKSHEETS
    importing
      !I_I__IXML_NODE type ref to IF_IXML_NODE optional
    returning
      value(E_V__TEXT) type STRING .

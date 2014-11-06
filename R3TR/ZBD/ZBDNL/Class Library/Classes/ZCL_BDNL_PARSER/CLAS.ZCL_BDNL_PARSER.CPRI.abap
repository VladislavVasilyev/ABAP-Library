*"* private components of class ZCL_BDNL_PARSER
*"* do not include other source files here!!!
private section.

  class-data GD_T__FILTERPOOLS type TY_T__FILTERPOOLS .
  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .
  data GD_T__VARIABLE type ZBNLT_T__VARIABLE .
  data GD_V__APPSET type UJ_APPSET_ID .
  data GD_V__APPLICATION type UJ_APPL_ID .
  data GD_V__FILENAME type UJ_DOCNAME .

  methods PARSER__FOR
    exporting
      !E_V__TABLENAME type ZBNLT_V__TABLENAME
      !E_V__PACKAGESIZE type I
      !E_F__WITH_KEY type RS_BOOL
    raising
      ZCX_BDNL_EXCEPTION .
  methods GET_STACK1
    returning
      value(STACK) type ZBNLT_S__STACK
    raising
      ZCX_BDNL_EXCEPTION
      CX_STATIC_CHECK .
  methods IF_EXPR
    returning
      value(RETURN) type STRING
    raising
      ZCX_BDNL_EXCEPTION .
  methods IF_PRIM
    returning
      value(RETURN) type STRING
    raising
      ZCX_BDNL_EXCEPTION .
  methods IF_TERM
    importing
      !GET type RS_BOOL
    returning
      value(RETURN) type STRING
    raising
      ZCX_BDNL_EXCEPTION .

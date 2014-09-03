*"* private components of class ZCL_BDNL_PARSER
*"* do not include other source files here!!!
private section.

  class-data GD_T__FILTERPOOLS type TY_T__FILTERPOOLS .
  class-data CR_O__CURSOR type ref to ZCL_BDNL_CURSOR .
  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .
  data GD_V__SCRIPT_PATH type STRING .
  data GD_T__VARIABLE type ZBNLT_T__VARIABLE .
  data GD_V__APPSET type UJ_APPSET_ID .
  data GD_V__APPLICATION type UJ_APPL_ID .
  data GD_V__FILENAME type UJ_DOCNAME .

  methods PARSER__CALC
    importing
      !I_T__CONTAINER type ZBNLT_T__STACK_CONTAINER
    exporting
      !E_V__TABLENAME type ZBNLT_V__TABLENAME
      !E_F__FOUND type RS_BOOL
    raising
      ZCX_BDNL_EXCEPTION .
  methods PARSER__FOR
    importing
      !I_T__CONTAINER type ZBNLT_T__STACK_CONTAINER
    exporting
      !E_V__TABLENAME type ZBNLT_V__TABLENAME
      !E_V__PACKAGESIZE type I
    raising
      ZCX_BDNL_EXCEPTION .
  methods GET_STACK1
    returning
      value(STACK) type ZBNLT_S__STACK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods IF_EXPR
    importing
      !GET type RS_BOOL
      !I_V__TURN type I optional
    returning
      value(RETURN) type STRING
    raising
      ZCX_BDNL_EXCEPTION .
  methods IF_PRIM
    importing
      !GET type RS_BOOL
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

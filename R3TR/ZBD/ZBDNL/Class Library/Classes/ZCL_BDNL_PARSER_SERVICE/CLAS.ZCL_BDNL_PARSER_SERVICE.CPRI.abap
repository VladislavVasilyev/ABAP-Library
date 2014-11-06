*"* private components of class ZCL_BDNL_PARSER_SERVICE
*"* do not include other source files here!!!
private section.

  data GD_T__CHECK type ZBNLT_T__STACK_CHECK .
  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .

  methods CONSTRUCTOR
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR .
  methods CHECK_EXPR
    importing
      !GET type RS_BOOL
      !I_V__TURN type I optional
    returning
      value(RETURN) type ZBNLT_S__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CHECK_PRIM
    importing
      !GET type RS_BOOL
    returning
      value(RETURN) type ZBNLT_S__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CHECK_TERM
    importing
      !GET type RS_BOOL
    returning
      value(RETURN) type ZBNLT_S__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods PROCESS_FUNCTION
    exporting
      !E_V__FUNCNAME type STRING
      !E_T__PARAM type ZBNLT_T__FUNC_PARAM
      !E_R__DATA type ref to DATA
    raising
      ZCX_BDNL_EXCEPTION .

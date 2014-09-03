*"* private components of class ZCL_BDNL_PARSER_CALC
*"* do not include other source files here!!!
private section.

  data GD_T__CHECK type ZBNLT_T__STACK_CHECK .
  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .
  data GD_S__ASSIGN type ZBNLT_S__STACK_ASSIGN .
  data GD_T__CONTAINERS type ZBNLT_T__STACK_CONTAINER .
  data GD_V__TABLENAME type ZBNLT_V__TABLENAME .
  data GD_V__FOR_TABLE type ZBNLT_V__TABLENAME .

  methods GET_CHECK
    importing
      !I_V__TURN type I
    returning
      value(E_T__CHECK) type ZBNLT_T__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION .
  methods CHECK_EXPR
    importing
      !GET type RS_BOOL
      !I_V__TURN type I optional
    returning
      value(RETURN) type ZBNLT_S__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods MATH
    exporting
      !E_T__VARIBLE type ZBNLT_T__MATH_VAR
      !E_V__EXP type STRING
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
  methods PRIM
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
    raising
      ZCX_BDNL_EXCEPTION .

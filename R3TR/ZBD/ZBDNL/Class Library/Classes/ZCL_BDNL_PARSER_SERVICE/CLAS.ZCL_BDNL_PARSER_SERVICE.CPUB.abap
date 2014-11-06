class ZCL_BDNL_PARSER_SERVICE definition
  public
  final
  create private .

*"* public components of class ZCL_BDNL_PARSER_SERVICE
*"* do not include other source files here!!!
public section.
  type-pools ZBNLT .

  class-methods GET_ASSIGN_FUNCTION
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
    exporting
      !E_R__DATA type ref to DATA
      !E_T__FUNCTION type ZBNLT_T__FUNCTION
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_CHECK
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
      !I_V__TURN type I
    returning
      value(E_T__CHECK) type ZBNLT_T__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_FUNC
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
    exporting
      !E_V__FUNCNAME type STRING
      !E_T__PARAM type ZBNLT_T__FUNC_PARAM
      !E_R__DATA type ref to DATA
    raising
      ZCX_BDNL_EXCEPTION .
  class-methods GET_CH
    importing
      !I_O__OBJ type ref to ZCL_BD00_APPL_TABLE
      !I_V__DIM type UJ_DIM_NAME
      !I_V__ATTR type UJ_ATTR_NAME
      !I_R__DATA type ref to DATA
    exporting
      !E_S__FUNCTION type ZBNLT_S__FUNCTION .
  class-methods CREATE_ASSIGN_FUNCTION
    importing
      !I_S__FUNCTION type ZBNLT_S__CUST_LINK
    exporting
      !E_T__FUNCTION type ZBNLT_T__FUNCTION
    raising
      ZCX_BD00_CREATE_OBJ .

class ZCL_BDNL_PARSER_CALC definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_PARSER_CALC
*"* do not include other source files here!!!
public section.
  type-pools ZBNLT .

  constants ERR_INDEX type I value -1. "#EC NOTEXT
  constants END_TOKEN type I value -1. "#EC NOTEXT

  methods CONSTRUCTOR
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
      !I_V__TABLENAME type ZBNLT_V__TABLENAME
      !I_V__FOR_TABLE type ZBNLT_V__TABLENAME .
  methods GET_STACK
    exporting
      !E_T__LINK type ZBNLT_T__CUST_LINK
      !E_V__EXP type STRING
      !E_T__VARIABLE type ZBNLT_T__MATH_VAR
      !E_T__CHECK type ZBNLT_T__STACK_CHECK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .

class ZCL_BDNL_PARSER_FOR definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_PARSER_FOR
*"* do not include other source files here!!!
public section.

  constants ERR_INDEX type I value -1. "#EC NOTEXT
  constants END_TOKEN type I value -1. "#EC NOTEXT
  type-pools ZBNLT .
  data GD_T__CLEAR type ZBNLT_T__CLEAR .
  data GD_T__PRINT type ZBNLT_T__PRINT .
  data GD_T__COMMIT type ZBNLT_T__COMMIT .
  data GD_T__WHERE type ZBNLT_T__CUST_LINK .

  methods GET_STACK
    returning
      value(E_T__RULES) type ZBNLT_T__FOR_RULES
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CONSTRUCTOR
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
      !I_V__FOR_TABLE type ZBNLT_V__TABLENAME
      !I_F__WITH_KEY type RS_BOOL .

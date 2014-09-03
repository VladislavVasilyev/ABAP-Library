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
  data GD_T__COMMIT type ZBNLT_T__COMMIT .

  methods GET_STACK
    returning
      value(E_T__RULES) type ZBNLT_T__FOR_RULES
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CONSTRUCTOR
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
      !I_T__CONTAINER type ZBNLT_T__STACK_CONTAINER
      !I_V__FOR_TABLE type ZBNLT_V__TABLENAME .

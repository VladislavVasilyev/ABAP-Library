class ZCL_BDNL_PARSER_VARIABLES definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_PARSER_VARIABLES
*"* do not include other source files here!!!
public section.
  type-pools ZBNLT .

  methods GET_VAR
    raising
      ZCX_BDNL_EXCEPTION
      CX_STATIC_CHECK .
  methods CONSTRUCTOR
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
      !_DEL_I_T__CONTAINERS type ZBNLT_T__STACK_CONTAINER optional .

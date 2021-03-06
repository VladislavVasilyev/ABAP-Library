class ZCL_BDNL_PARSER_CONTAINER definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_PARSER_CONTAINER
*"* do not include other source files here!!!
public section.
  type-pools ZVCSC .
  type-pools ZVCST .

  constants END_TOKEN type I value -1. "#EC NOTEXT
  constants ERR_INDEX type I value -1. "#EC NOTEXT

  type-pools ZBNLT .
  methods GET_STACK
    returning
      value(STACK) type ZBNLT_T__CONTAINER
    raising
      ZCX_BDNL_EXCEPTION
      CX_STATIC_CHECK .
  methods GET_FILTERS
    returning
      value(STACK) type ZBNLT_T__STACK_RANGE
    raising
      ZCX_BDNL_EXCEPTION
      CX_STATIC_CHECK .
  methods CONSTRUCTOR
    importing
      !I_R__CURSOR type ref to ZCL_BDNL_CURSOR
      !I_T__RANGE type ZBNLT_T__STACK_RANGE optional
      !I_V__TURN type I optional
      !_DEL_I_T__CONTAINERS type ZBNLT_T__STACK_CONTAINER optional .

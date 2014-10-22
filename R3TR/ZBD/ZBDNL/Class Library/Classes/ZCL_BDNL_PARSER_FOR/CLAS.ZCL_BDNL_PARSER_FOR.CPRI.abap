*"* private components of class ZCL_BDNL_PARSER_FOR
*"* do not include other source files here!!!
private section.

  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .
  type-pools ZBNLT .
  data GD_T__RULES type ZBNLT_T__FOR_RULES .
  data GD_T__STACK type ZBNLT_T__STACK_SEARCH .
  data GD_T__CONTAINERS type ZBNLT_T__STACK_CONTAINER .
  data GD_V__FOR_TABLE type ZBNLT_V__TABLENAME .
  data GD_F__WITH_KEY type rs_bool .

  methods READ_FROM
    exporting
      !DEFAULT type STRING
    raising
      ZCX_BDNL_EXCEPTION .
  methods READ_WITH_KEY
    importing
      !I_V__TABLENAME type ZBNLT_V__TABLENAME
    exporting
      !E_T__CUSTLINK type ZBNLT_T__CUST_LINK
    raising
      ZCX_BDNL_EXCEPTION .
  methods PARSER__CALC
    importing
      !I_T__CONTAINER type ZBNLT_T__STACK_CONTAINER
    exporting
      !E_V__TABLENAME type ZBNLT_V__TABLENAME
      !E_F__FOUND type RS_BOOL
    raising
      ZCX_BDNL_EXCEPTION .
  methods PROCESS_FUNCTION
    exporting
      !E_V__FUNCNAME type STRING
      !E_T__PARAM type ZBNLT_T__FUNC_PARAM
      !E_R__DATA type ref to DATA
    raising
      ZCX_BDNL_EXCEPTION .
  methods READ_STATEMENTS
    exporting
      !E_S__STACK type ZBNLT_S__STACK_SEARCH
    raising
      ZCX_BDNL_EXCEPTION .
  methods PRIM
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .

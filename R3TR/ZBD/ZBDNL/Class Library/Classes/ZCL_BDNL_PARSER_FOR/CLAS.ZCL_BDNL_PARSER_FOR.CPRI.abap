*"* private components of class ZCL_BDNL_PARSER_FOR
*"* do not include other source files here!!!
private section.

  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .
  data GD_T__RULES type ZBNLT_T__FOR_RULES .
  data GD_V__FOR_TABLE type ZBNLT_V__TABLENAME .
  data GD_F__WITH_KEY type RS_BOOL .

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
    exporting
      !E_V__TABLENAME type ZBNLT_V__TABLENAME
      !E_F__FOUND type RS_BOOL
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

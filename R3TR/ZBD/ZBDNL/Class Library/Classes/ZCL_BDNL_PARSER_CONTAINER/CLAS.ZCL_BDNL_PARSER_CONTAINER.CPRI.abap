*"* private components of class ZCL_BDNL_PARSER_CONTAINER
*"* do not include other source files here!!!
private section.

  type-pools ZBNLT .
  data GD_T__CONTAINERS type ZBNLT_T__STACK_CONTAINER .
  data GD_T__RANGE type ZBNLT_T__STACK_RANGE .
  data GD_T__STACK type ZBNLT_T__STACK_CONTAINER .
  data GD_V__TURN type I .
  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .

  methods CHECK_TABLE
    importing
      !TABLENAME type ZBNLT_V__TABLENAME
    raising
      ZCX_BDNL_EXCEPTION .
  methods FILTER_STATEMENTS
    exporting
      !E_S__STACK type ZBNLT_S__STACK_RANGE
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods FILTER_PRIM
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods PROCESS_FUNCTION
    returning
      value(E_T__PARAM) type ZBNLT_T__PARAM
    raising
      ZCX_BDNL_EXCEPTION .
  type-pools ZBD0T .
  methods SELECT_PARAM_FIELDS
    importing
      !I_V__TYPE_TABLE type STRING
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !I_APPL_OBJ type ref to ZCL_BD00_APPLICATION
    exporting
      !E_T__ALIAS type ZBD00_T_ALIAS
      !E_T__DIMLIST type ZBD00_T_CH_KEY
      !E_V__TECH_TYPE_TABLE type ZBD00_TYPE_APPL_TABLE
      !E_T__DIMENSION type ZBD0T_TY_T_DIM
      !E_T__KEY_LIST type ZBD0T_TY_T_KF
      !E_F__WRITE type RS_BOOL
    raising
      ZCX_BDNL_EXCEPTION .
  methods CMD_FROM
    exporting
      !E_APPSET_ID type UJ_APPSET_ID
      !E_APPL_ID type UJ_APPL_ID
      !E_DIM_NAME type UJ_DIM_NAME
      !E_APPL_OBJ type ref to ZCL_BD00_APPLICATION
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods SELECT_PARAM_INTO
    exporting
      !E_V__TYPE_TABLE type STRING
      !E_V__TABLENAME type ZBNLT_V__TABLENAME
    raising
      ZCX_BDNL_EXCEPTION .
  methods TABLE_PARAM_CONST
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !I_F__FORDOWN type RS_BOOL
    exporting
      !E_T__CONST type ZBD0T_TY_T_CONSTANT
    raising
      ZCX_BDNL_EXCEPTION .
  methods SELECT_PARAM_WHERE
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID optional
      !I_APPL_OBJ type ref to ZCL_BD00_APPLICATION optional
    exporting
      !E_T__RANGE type UJ0_T_SEL
    raising
      ZCX_BDNL_EXCEPTION .
  methods SELECT_WHERE_OPT
    importing
      !TOKEN type STRING
    exporting
      !OPTION type DDOPTION
    raising
      ZCX_BDNL_EXCEPTION .
  methods PRIM
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods SELECT_STATEMENTS
    exporting
      !E_S__STACK type ZBNLT_S__STACK_CONTAINER
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CLEAR_STATEMENTS
    exporting
      !E_S__STACK type ZBNLT_S__STACK_CONTAINER
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods TABLE_STATEMENTS
    exporting
      !E_S__STACK type ZBNLT_S__STACK_CONTAINER
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .

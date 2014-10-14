*"* private components of class ZCL_BDNL_RUN_LOGIC
*"* do not include other source files here!!!
private section.

  types:
    begin of ty_s__reestr
         , script type ref to zcl_bdnl_run_logic
         , end of ty_s__reestr .

  data GD_F__RSPC type RS_BOOL .
  data GD_V__CHECK_INDEX type I .
  data GD_V__CNT_CLEAR type STRING .
  data GD_V__SCRIPT type I .
  data GD_V__TURN type I .
  data GR_O__PARSER type ref to ZCL_BDNL_PARSER .
  data GR_O__RFC_TASK type ref to ZCL_BD00_RFC_TASK .
  data GR_T__CHECK type ref to ZBNLT_S__CHECK .

  methods CHECK_EXPR
    importing
      !GET type RS_BOOL
    returning
      value(RETURN) type STRING .
  methods GET_NR_PACK
    importing
      !I_V__NR_PACK type I
      !I_V__SIZE type I default 5
    returning
      value(E_V__TEXT) type STRING .
  methods CHECK_PRIM
    importing
      !GET type RS_BOOL
    returning
      value(RETURN) type STRING .
  methods GET_CH
    importing
      !I_O__OBJ type ref to ZCL_BD00_APPL_TABLE
      !I_V__DIM type UJ_DIM_NAME
      !I_V__ATTR type UJ_ATTR_NAME
      !I_R__DATA type ref to DATA
    exporting
      !E_S__FUNCTION type ZBNLT_S__FUNCTION .
  methods CONVERT_TIME
    importing
      !I_V__START type TZNTSTMPL
      !I_V__END type TZNTSTMPL
    exporting
      !E_V__DATA_START type STRING
      !E_V__TIME_START type STRING
      !E_V__DELTA_TIME type STRING .
  methods GET_TABLE
    importing
      !I_V__TABLENAME type ZBNLT_V__TABLENAME
    returning
      value(E_S__TABLE) type ref to ZBNLT_S__CONTAINERS .
  methods ASSIGN
    importing
      !I type I
      !F_FOUND type RS_BOOL .
  methods ASSIGN_FUNCTION_____________ST
    importing
      !I_S__FUNCTION type ZBNLT_S__CUST_LINK
      !I_V__TURN type I
      !I_S__FOR type ZBNLT_S__FOR
    exporting
      !E_T__FUNCTION type ZBNLT_T__FUNCTION
    raising
      ZCX_BD00_CREATE_OBJ .
  methods ASSIGN_FUNCTION_____________NV
    importing
      !I_S__FUNCTION type ZBNLT_S__CUST_LINK
      !I_V__TURN type I
      !I_S__FOR type ZBNLT_S__FOR
    exporting
      !E_T__FUNCTION type ZBNLT_T__FUNCTION
    raising
      ZCX_BD00_CREATE_OBJ .
  methods ASSIGN_FUNCTION
    importing
      !I_S__FUNCTION type ZBNLT_S__CUST_LINK
      !I_V__TURN type I
      !I_S__FOR type ZBNLT_S__FOR
    exporting
      !E_T__FUNCTION type ZBNLT_T__FUNCTION
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_ASSIGN_RULE
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    exporting
      !E_T__ASSIGN type ZBNLT_T__ASSIGN
      !E_T__ASSIGN_NOT_FOUND type ZBNLT_T__ASSIGN
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_ASSIGN_RULE__________NV
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    exporting
      !E_T__ASSIGN type ZBNLT_T__ASSIGN
      !E_T__ASSIGN_NOT_FOUND type ZBNLT_T__ASSIGN
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_ASSIGN_RULE__________ST
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    exporting
      !E_T__ASSIGN type ZBNLT_T__ASSIGN
      !E_T__ASSIGN_NOT_FOUND type ZBNLT_T__ASSIGN
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_SEARCH_RULE
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    returning
      value(E_T__SEARCH) type ZBNLT_T__SEARCH
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_SEARCH_RULE__________NV
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    returning
      value(E_T__SEARCH) type ZBNLT_T__SEARCH
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_SEARCH_RULE__________ST
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    returning
      value(E_T__SEARCH) type ZBNLT_T__SEARCH
    raising
      ZCX_BD00_CREATE_OBJ .
  methods SEARCH
    importing
      !I type I .
  methods WORK_CIRCLE
    importing
      !I_S__FOR type ZBNLT_S__FOR
    raising
      ZCX_BD00_CREATE_OBJ .
  methods WORK_CIRCLE_________________NV
    importing
      !I_S__FOR type ZBNLT_S__FOR
    raising
      ZCX_BD00_CREATE_OBJ .
  methods WORK_CIRCLE_________________ST
    importing
      !I_S__FOR type ZBNLT_S__FOR
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CLEAR_CONTAINERS____________ST
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CLEAR_CONTAINERS____________NV
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CLEAR_CONTAINERS
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_CONTAINER____________ST
    importing
      !I_S__FOR type ZBNLT_S__FOR optional
      !I_V__TABLENAME type ZBNLT_V__TABLENAME
    returning
      value(E_S__TABLE) type ref to ZBNLT_S__CONTAINERS
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_CONTAINER____________NV
    importing
      !I_S__FOR type ZBNLT_S__FOR optional
      !I_V__TABLENAME type ZBNLT_V__TABLENAME
      !I_V__PACKAGESIZE type I optional
    returning
      value(E_S__TABLE) type ref to ZBNLT_S__CONTAINERS
    raising
      ZCX_BD00_CREATE_OBJ .
  methods CREATE_CONTAINER
    importing
      !I_S__FOR type ZBNLT_S__FOR optional
      !I_V__TABLENAME type ZBNLT_V__TABLENAME
    returning
      value(E_S__TABLE) type ref to ZBNLT_S__CONTAINERS
    raising
      ZCX_BD00_CREATE_OBJ .

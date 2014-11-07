*"* private components of class ZCL_BDNL_RUN_LOGIC
*"* do not include other source files here!!!
private section.

  types:
    begin of ty_s__reestr
         , script type ref to zcl_bdnl_run_logic
         , end of ty_s__reestr .

  data GD_V__CHECK_INDEX type I .
  data GD_V__SCRIPT type I .
  data GD_V__TURN type I .
  data GR_O__PARSER type ref to ZCL_BDNL_PARSER .
  data GR_O__RFC_TASK type ref to ZCL_BD00_RFC_TASK .
  data GR_T__CHECK type ref to ZBNLT_S__CHECK .
  data:
    GD_T__SEARCHMESSAGE type standard table of string .
  data GD_V__NUMBER_RULES type I value 0. "#EC NOTEXT .

  methods CREATE_RANGE_REF
    importing
      !TYPE type STRING optional
      !I_REF type ref to DATA optional
    returning
      value(REF) type ref to DATA .
  methods CREATE_CHECK
    importing
      !I_T__CHECK type ZBNLT_T__STACK_CHECK
    exporting
      value(E_T__CHECK) type ZBNLT_T__CHECK
      !E_T__FUNCTION type ZBNLT_T__FUNCTION
    raising
      ZCX_BD00_CREATE_OBJ .
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
  methods CONVERT_TIME
    importing
      !I_V__START type TZNTSTMPL
      !I_V__END type TZNTSTMPL
    exporting
      !E_V__DATA_START type STRING
      !E_V__TIME_START type STRING
      !E_V__DELTA_TIME type STRING .
  methods ASSIGN
    importing
      !I type I
      !F_FOUND type RS_BOOL
      !I_F__CONT type RS_BOOL optional
    returning
      value(E_F__CONTINUE) type RS_BOOL
    raising
      CX_STATIC_CHECK
      CX_DYNAMIC_CHECK .
  methods CREATE_ASSIGN_RULE
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    exporting
      !E_T__ASSIGN type ZBNLT_T__ASSIGN
      !E_T__ASSIGN_NOT_FOUND type ZBNLT_T__ASSIGN
      !E_F__CONTINUE type RS_BOOL
    raising
      ZCX_BD00_CREATE_OBJ
      ZCX_BDNL_WORK_RULE
      ZCX_BD00_CREATE_RULE .
  methods CREATE_SEARCH_RULE
    importing
      !I_S__FOR type ZBNLT_S__FOR
      !I_V__TURN type I
    exporting
      !E_T__SEARCH type ZBNLT_T__SEARCH
      !E_S__SEARCH_FOR type ZBNLT_S__SEARCH
    raising
      ZCX_BD00_CREATE_OBJ
      ZCX_BDNL_WORK_RULE
      ZCX_BD00_CREATE_RULE .
  methods SEARCH
    importing
      !I type I
    returning
      value(E_F__CONTINUE) type RS_BOOL
    raising
      CX_DYNAMIC_CHECK
      CX_STATIC_CHECK .
  methods WORK_CIRCLE
    importing
      !I_S__FOR type ZBNLT_S__FOR
    raising
      CX_STATIC_CHECK
      CX_DYNAMIC_CHECK .
  methods CLEAR_CONTAINERS
    raising
      ZCX_BD00_CREATE_OBJ
      CX_STATIC_CHECK .

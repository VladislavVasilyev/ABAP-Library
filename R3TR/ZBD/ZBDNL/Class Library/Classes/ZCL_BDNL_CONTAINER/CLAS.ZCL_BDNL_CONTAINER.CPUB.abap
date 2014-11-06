class ZCL_BDNL_CONTAINER definition
  public
  final
  create private .

*"* public components of class ZCL_BDNL_CONTAINER
*"* do not include other source files here!!!
public section.
  type-pools ZBNLT .

  types:
    begin of ty_s__reestr
            , tablename      type zbnlt_v__tablename
            , script         type string
            , container      type ref to zcl_bdnl_container
            , end of ty_s__reestr .
  types:
    ty_t__reestr type hashed table of ty_s__reestr with unique key tablename script .
  types:
    begin of ty_s__log
            , tablename      type zbnlt_v__tablename
            , command        type string
            , script         type string
            , n_script       type i
            , n_turn         type i
            , n_for          type i
            , sequence       type i
            , n_actual       type i
            , f_master       type rs_bool
            , table          type ref to zcl_bd00_appl_table
            , skip_rows      type i
            , end of ty_s__log .
  types:
    ty_t__log type sorted table of ty_s__log with unique key n_script n_turn n_for sequence tablename .

  data GD_F__CLEAR type RS_BOOL read-only .
  data GD_F__INIT type RS_BOOL read-only .
  data GD_V__COMMAND type STRING read-only .
  data:
    gd_v__read_mode    type c length 1 read-only .
  data GD_V__TABLENAME type ZBNLT_V__TABLENAME read-only .
  data GD_V__TYPE_TABLE type STRING read-only .
  data GR_O__CONTAINER type ref to ZCL_BD00_APPL_TABLE read-only .
  class-data CD_T__LOG type TY_T__LOG read-only .

  class-methods ADD_SKIP .
  methods PRINT .
  methods GET_LINE
    returning
      value(LINE) type STRING .
  class-methods ACTUAL_CTABLES .
  methods NEXT_PACK
    returning
      value(E_ST) type RS_BOOL .
  type-pools ZBD0T .
  methods NEXT_LINE
    importing
      !ID type ZBD0T_ID_RULES
    returning
      value(E_ST) type RS_BOOL .
  class-methods CLEAR_FOR_REESTR .
  class-methods SET_CURRENT_SCRIPT
    importing
      !SCRIPT type UJ_DOCNAME
      !APPSET_ID type UJ_APPSET_ID
      !APPL_ID type UJ_APPL_ID .
  class-methods CHECK_TABLE_DECL
    importing
      !TABLENAME type ZBNLT_V__TABLENAME
    raising
      ZCX_BDNL_SYNTAX_ERROR .
  class-methods CHECK_TABLE
    importing
      !TABLENAME type ZBNLT_V__TABLENAME
    returning
      value(E_S__PARAM) type ZBNLT_S__STACK_CONTAINER
    raising
      ZCX_BDNL_SYNTAX_ERROR .
  class-methods CHECK_DIM
    importing
      !TABLENAME type ZBNLT_V__TABLENAME
      !DIMENSION type UJ_DIM_NAME optional
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(E_S__PARAM) type ZBNLT_S__STACK_CONTAINER
    raising
      ZCX_BDNL_SYNTAX_ERROR .
  class-methods SET_CURRENT_TURN
    importing
      !TURN type I .
  class-methods SET_CURRENT_FOR
    importing
      !TURN type I .
  methods SET_TURN
    importing
      !TURN type I .
  methods SET_CLEAR .
  methods SET_INIT
    importing
      !INIT type RS_BOOL .
  methods SET_COMMAND
    importing
      !COMMAND type STRING .
  class-methods GET_TABLE
    importing
      !I_S__PARAM type ZBNLT_S__STACK_CONTAINER
    returning
      value(E_O__CONTAINER) type ref to ZCL_BDNL_CONTAINER .
  type-pools ABAP .
  class-methods CREATE_CONTAINER
    importing
      !TABLENAME type ZBNLT_V__TABLENAME
      !PACKAGE_SIZE type I default -1
      !F_MASTER type RS_BOOL default ABAP_FALSE
    returning
      value(CONTAINER) type ref to ZCL_BDNL_CONTAINER
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_CONTAINER
    importing
      !TABLENAME type ZBNLT_V__TABLENAME
    returning
      value(CONTAINER) type ref to ZCL_BDNL_CONTAINER .
  class-methods GET_CONTAINER_CLEAR
    returning
      value(CONTAINER) type TY_T__REESTR .
  class-methods GET_CONTAINER_OBJECT
    importing
      !OBJECT type ref to ZCL_BD00_APPL_TABLE
    returning
      value(CONTAINER) type ref to ZCL_BDNL_CONTAINER .

class ZCL_BD00_APPL_TABLE definition
  public
  inheriting from ZCL_BD00_APPL_CTRL
  create public

  global friends ZCL_BD00_APPL_CTRL
                 ZCL_BD00_INT_TABLE .

*"* public components of class ZCL_BD00_APPL_TABLE
*"* do not include other source files here!!!
public section.
  type-pools UJA00 .

  events CREATE_APPL
    exporting
      value(IO_APPL) type ref to ZCL_BD00_APPL_TABLE .
  events EV_READ_DATA_AFTER_RFC_CALL .
  events EV_AUTO_WRITE_BACK .

  methods DELETE_LINE .
  methods RESET_INDEX .
  type-pools ABAP .
  methods WRITE_BACK
    importing
      !IF_CLEAR type RS_BOOL default ABAP_FALSE .
  type-pools ZBD0C .
  methods ADD_LINE
    importing
      !MODE type ZBD00_MODE_ADD_LINE default ZBD0C_MODE_ADD_LINE-COLLECT
      !IO_LINE type ref to ZCL_BD00_APPL_CTRL optional .
  type-pools ZBD0T .
  methods NEXT_LINE
    importing
      !ID type ZBD0T_ID_RULES optional
    returning
      value(E_ST) type ZBD0C_TY_READ_ST .
  methods NEXT_LINE_1
    importing
      !CLASS type ref to ZIF_BD00_INT_TABLE optional
    returning
      value(E_ST) type ZBD0C_TY_READ_ST .
  methods NEXT_PACK
    importing
      !MODE type C
    returning
      value(E_ST) type RS_BOOL .
  methods CONSTRUCTOR
    importing
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IF_AUTO_SAVE type RS_BOOL default ABAP_FALSE
      !IT_ALIAS type ZBD00_T_ALIAS optional
      !IT_RANGE type UJ0_T_SEL optional
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !IT_CONST type ZBD0T_TY_T_CONSTANT optional
      !IF_SUPPRESS_ZERO type RS_BOOL default ABAP_TRUE
      !I_PACKAGESIZE type I optional
      !IF_INVERT type RS_BOOL default ABAP_FALSE
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_INFOCUBE
    importing
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IT_ALIAS type ZBD00_T_ALIAS optional
      !IT_RANGE type UJ0_T_SEL optional
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !IF_SUPPRESS_ZERO type RS_BOOL default ABAP_TRUE
      !I_PACKAGESIZE type I optional
      !I_INFOCUBE type RSINFOPROV
      !IT_KYF_LIST type ZBD0T_TY_T_KF optional
    returning
      value(E_INFOCUBE) type ref to ZCL_BD00_APPL_TABLE .
  class-methods GET_DIMENSION
    importing
      !IT_ALIAS type ZBD00_T_ALIAS optional
      !IT_RANGE type UJ0_T_SEL optional
      !I_APPSET_ID type UJ_APPSET_ID
      !I_DIMENSION type UJ_DIM_NAME
      !IT_ATTR_LIST type UJA_T_ATTR_NAME
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
    returning
      value(E_INFOCUBE) type ref to ZCL_BD00_APPL_TABLE .
  class-methods GET_APPL_CUST
    importing
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IT_ALIAS type ZBD00_T_ALIAS optional
      !IT_RANGE type UJ0_T_SEL optional
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !IF_SUPPRESS_ZERO type RS_BOOL default ABAP_TRUE
      !I_PACKAGESIZE type I optional
      !IT_KYF_LIST type ZBD0T_TY_T_KF optional
      !I_APPSET_ID type UJ_APPSET_ID
    returning
      value(E_INFOCUBE) type ref to ZCL_BD00_APPL_TABLE .
  methods SET_RULE_SEARCH
    importing
      !IO_DEFAULT type ref to ZCL_BD00_APPL_CTRL optional
      !IT_LINK type ZBD0T_TY_T_LINK_KEY optional
      !IT_RANGE type ZBD0T_TY_T_RANGE_KF optional
      !IT_CUST_LINK type ZBD0T_TY_T_CUSTOM_LINK optional
    returning
      value(E_ID) type ZBD0T_ID_RULES .

*"* private components of class ZCL_BD00_APPLICATION
*"* do not include other source files here!!!
private section.

  types:
    begin of ty_s_reestr
      , appset_id type uj_appset_id
      , appl_id   type uj_appl_id
      , dimension type uj_dim_name
      , infocube  type rsinfoprov
      , obj       type ref to zcl_bd00_application
    , end of ty_s_reestr .
  types:
    ty_t_reestr type sorted table of ty_s_reestr with unique key appset_id appl_id dimension infocube .

  class-data REESTR type TY_T_REESTR .

  methods CONSTRUCTOR
    importing
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !I_INFOCUBE type RSINFOPROV optional
      !I_DIMENSION type UJ_DIM_NAME optional
    raising
      ZCX_BD00_CREATE_OBJ .
  methods GET_DIMENSION_BP .
  methods GET_DIMENSION_BPC .
  methods GET_DIMENSION_MBR .
  methods GET_DIMENSION_BPC_CUST .

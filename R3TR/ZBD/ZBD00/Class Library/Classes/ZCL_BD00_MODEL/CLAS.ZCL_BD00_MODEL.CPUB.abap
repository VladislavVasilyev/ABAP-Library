class ZCL_BD00_MODEL definition
  public
  final
  create private

  global friends ZCL_BD00_APPL_LINE
                 ZCL_BD00_APPL_TABLE .

*"* public components of class ZCL_BD00_MODEL
*"* do not include other source files here!!!
public section.
  type-pools ZBD0C .
  type-pools ZBD0T .

  types:
    begin of ty_s_alias.
    types tech_name type RSCHANM.
    types tech_alias type RSALIAS.
  types end of ty_s_alias .
  types:
    ty_t_alias type hashed table of ty_s_alias with unique key tech_alias .
  types:
    begin of ty_s_dim_list.
    include type zbd00_s_dimn.
    types orderby type zbd00_s_ch_key-orderby.
    types f_key type zbd00_s_ch_key-f_key.
    types ty_elem type ref to cl_abap_datadescr.
    types end   of ty_s_dim_list .
  types:
    ty_t_dim_list type hashed table of ty_s_dim_list
                            with unique key dimension attribute .
  types:
    begin of ty_s_key_list
            , nkey type zbd00_s_bpc_dim-nkey
            , type type zbd00_s_bpc_dim-type
            , dimensions type ty_t_dim_list
          , end   of ty_s_key_list .
  types:
    ty_t_key_list type sorted table of ty_s_key_list with unique key nkey .

  constants:
    cs_pk type c value `PK` length 2 .
  type-pools ABAP .
  data GD_F__COMPLETE_KEY type RS_BOOL read-only value ABAP_TRUE. "#EC NOTEXT .
  data GD_F__WRITE_ON type RS_BOOL read-only .
  data GR_O__APPLICATION type ref to ZCL_BD00_APPLICATION read-only .
  data GR_T__DIMENSION type ref to TY_T_DIM_LIST read-only .
  data:
    begin of gd_s__handle read-only.
    data begin of st.
    data appl_name type ref to cl_abap_structdescr.
    data tech_name type ref to cl_abap_structdescr.
    data end of st.
    data begin of tab.
    data appl_name type ref to cl_abap_tabledescr.
    data tech_name type ref to cl_abap_tabledescr.
    data end of tab.
    data end of gd_s__handle .
  data GD_T__KEY_LIST type TY_T_KEY_LIST read-only .
  data GD_T__SFC type RSDRI_T_SFC read-only .
  data GD_T__SFK type RSDRI_T_SFK read-only .
  data GD_V__SIGNEDDATA type UJ_DIM_NAME read-only .
  data GD_T__SIGNEDDATA type ZBD0T_TY_T_KF read-only .
  data GD_V__TYPE_PK type ZBD00_TYPE_APPL_TABLE read-only .
  data GD_T__DIM_LIST type ZBD00_ST_CH_KEY read-only .
  data GD_T__COMPONENTS type ABAP_KEYDESCR_TAB read-only .
  data GD_T__KEY type ABAP_KEYDESCR_TAB read-only .
  data GD_T__TECH_ALIAS type TY_T_ALIAS read-only .
  data GD_T__BPC_ALIAS type ZBD00_T_ALIAS read-only .

  methods GET_TECH_ALIAS
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(ALIAS) type RSALIAS .
  methods GET_DTELNM
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(DTELNM) type ROLLNAME .
  methods GET_DIM_NAME
    importing
      !TECH_ALIAS type RSALIAS
    returning
      value(DIM_NAME) type ZBD0T_TY_S_DIM .
  methods GET_APPL
    returning
      value(RESULT) type ref to ZCL_BD00_APPLICATION .
  class-methods GET_MODEL
    importing
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IT_ALIAS type ZBD00_T_ALIAS optional
    returning
      value(E_OBJ) type ref to ZCL_BD00_MODEL
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_MODEL_CUST_APPL
    importing
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IT_ALIAS type ZBD00_T_ALIAS optional
    returning
      value(E_OBJ) type ref to ZCL_BD00_MODEL
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_MODEL_DIMENSION
    importing
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IT_ALIAS type ZBD00_T_ALIAS optional
      !I_DIMENSION type UJ_DIM_NAME optional
    returning
      value(E_OBJ) type ref to ZCL_BD00_MODEL
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_MODEL_INFOCUBE
    importing
      !IT_DIM_LIST type ZBD00_T_CH_KEY optional
      !I_TYPE_PK type ZBD00_S_BPC_DIM-TYPE default ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
      !IT_ALIAS type ZBD00_T_ALIAS optional
      !I_INFOCUBE type RSINFOPROV
      !IT_KYF_LIST type ZBD0T_TY_T_KF optional
    returning
      value(E_OBJ) type ref to ZCL_BD00_MODEL
    raising
      ZCX_BD00_CREATE_OBJ .

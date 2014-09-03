class ZCL_BDCH_BADI definition
  public
  final
  create public .

*"* public components of class ZCL_BDCH_BADI
*"* do not include other source files here!!!
public section.
  type-pools UJA00 .
  type-pools UJR0 .

  interfaces IF_BADI_INTERFACE .
  interfaces IF_UJ_CUSTOM_LOGIC .

  types:
    ty_name_rfc_task type c length 8 .
  types:
    begin of ty_s_cur_context
        , appset_id type uj_appset_id
        , appl_id   type uj_appl_id
        , context   type ref to if_uj_context
      , end of ty_s_cur_context .
  types:
    begin of ty_s_dim_list
        , appset_id type uj_appset_id
        , dimension type uj_dim_name
        , data       type ref to data
      , end of ty_s_dim_list .
  types:
    begin of ty_s_filter
        , filter_key  type  uj_large_string
        , t_range  type uj0_t_sel
      , end of ty_s_filter .
  types:
    begin of ty_s_param
        , key type uj_large_string
        , val type uj_large_string
      , end of ty_s_param .
  types:
    begin of ty_s_log_read_write
        , type type i
        , nr_pack type i
        , read_ses type i
        , appset_id type uj_appset_id
        , appl_id type uj_appl_id
        , dimension type uj_dim_name
        , st_rec type ujr_s_status_records
        , time_start type tzntstmpl
        , time_end   type tzntstmpl
        , rfc_task   type ty_name_rfc_task
      , end of ty_s_log_read_write .
  types:
    begin of ty_s_insert_dim
         , field type uj_dim_name
         , key type rs_bool
       , end of ty_s_insert_dim .
  types:
    ty_t_insert_dim type standard table of ty_s_insert_dim .
  types:
    begin of ty_s_method
          , step type i
          , name type string
          , execute type string
          , time_start type tzntstmpl
          , time_end type tzntstmpl
          , packagesize type i
          , task type i
          , f_log type rs_bool
          , f_debug type rs_bool
          , f_mail type rs_bool
          , f_norun type rs_bool
          , nr_task type i
          , msgbox type string
      , end of ty_s_method .

  constants:
    begin of cs
       , compname_id      type abap_compname value uja00_cs_attr-id
       , task             type string value 'TASK'
       , debug            type string value 'DEBUG'
       , method           type string value 'METHOD'
       , class            type string value 'CLASS'
       , norun            type string value 'NORUN'
       , log              type string value 'LOG'
       , interface        type string value 'ZIF_RB_LOGISTICS~'
       , clear_appl       type string value 'APPL'
       , package          type string value 'PACKAGE'
       , all              type string value '%ALL%'
       , log_div          type string value '--------------------------------------------------------------------------------------------'
       , packagesize      type string value 'PACKAGESIZE'
       , msgbox           type string value 'MSGBOX'
       , mail             type string value 'MAIL'
       , log_pl           type c      value '1'
       , log_fl           type c      value '2'
       , log_pf           type c      value '3'
       , log_read_full    type i value 10
       , log_write_full   type i value 11
       , log_read_pack    type i value 20
       , log_transf_pack  type i value 21
       , log_write_pack   type i value 22
       , rfc_run          type c length 1 value 'R'
       , rfc_wait         type c length 1 value 'W'
       , rfc_free         type c length 1 value 'F'
      ,end   of cs .
  constants:
    begin of prs
        , mul    type c value '*'
        , div    type c value '/'
        , minus  type c value '-'
        , plus   type c value '+'
      ,  end of prs .

  type-pools ABAP .
  class CL_ABAP_TABLEDESCR definition load .
  interface ZIF_RB_DINAMIC load .
  class-methods GET_TABLE_REF
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !I_TYPE type ABAP_TABLEKIND default CL_ABAP_TABLEDESCR=>TABLEKIND_STD
      !IT_KEY_FIELD type ABAP_KEYDESCR_TAB optional
      !IT_DIM_FIELD type UJA_T_DIM_LIST optional
    returning
      value(E_REF) type ZIF_RB_DINAMIC=>TY_S_REF_TAB .
  class-methods GET_MBR_DATA
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_DIM_NAME type UJ_DIM_NAME
      !IT_ATTR_LIST type UJA_T_ATTR_NAME optional
      !IT_SEL type UJ0_T_SEL optional
      !IT_SEL_MBR type UJA_T_DIM_MEMBER optional
      !IF_HT type ABAP_BOOL default ABAP_FALSE
    returning
      value(E_DATA) type ZIF_RB_DINAMIC=>TY_S_REF_TAB .
  class-methods GET_STRUCT_REF
    importing
      !IT_DIM_FIELD type UJA_T_DIM_LIST
      !IF_KF type RS_BOOL default ABAP_FALSE
    returning
      value(REF) type ref to DATA .

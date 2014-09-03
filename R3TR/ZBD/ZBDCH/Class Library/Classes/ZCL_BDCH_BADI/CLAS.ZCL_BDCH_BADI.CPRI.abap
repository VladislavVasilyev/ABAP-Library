*"* private components of class ZCL_BDCH_BADI
*"* do not include other source files here!!!
private section.

  data DO_RFC_TASK type ref to ZCL_RB_RFC_TASK .
  data:
    dt_appl_range type hashed table of ty_s_filter with unique key filter_key .
  data DV_APPLICATION_ID type UJ_APPL_ID .
  data DV_APPSET_ID type UJ_APPSET_ID .
  data GT_CUR_CONTEXT type TY_S_CUR_CONTEXT .
  data:
    gt_dim_list type hashed table of ty_s_dim_list with unique key appset_id dimension .
  data:
    gt_param type standard table of ty_s_param .
  data DT_MESSAGE type UJ0_T_MESSAGE .
  data DT_MSGLOG type UJ0_T_MESSAGE .
  data DT_SEL type UJ0_T_SEL .
  data:
    ds_sel type line of uj0_t_sel .
  data:
    begin of ds_read_pack.
  data end_of_data type rs_bool .
  data split_occurred type rsdr0_split_occurred .
  data stats_guid type uj_stat_session .
  data first_call type rs_bool value abap_true.
  data rfc_wait_read type rs_bool.
  data log_ses type i .
  data count type i .
  data end of ds_read_pack .
  type-pools ABAP .
  data DT_KEY_FIELD type ABAP_KEYDESCR_TAB .
  data DT_ATTR_LIST type UJA_T_ATTR_NAME .
  data DT_DIM_FIELD type UJA_T_DIM_LIST .
  data DT_INSERT_DIM type TY_T_INSERT_DIM .
  data DS_INSERT_DIM type TY_S_INSERT_DIM .
  data:
    dt_run_method type table of string .
  data DS_KEY_SC type ref to DATA .
  data DS_KEY_TG type ref to DATA .
  data DV_TABIX type I .
  data:
    begin of ds_user.
  include type uj0_s_user .
  data email type uje_user-email.
  data package_id type uj_package_id.
  data end of ds_user .
  class-data:
    ds_mailtxt type standard table of soli .
  class-data:
    begin of ds_time_process.
  class-data start type tzntstmpl.
  class-data end   type tzntstmpl.
  class-data end of ds_time_process .
  data:
    begin of ds_method.
    data  class type string.
  include type ty_s_method.
  data rw_log type standard table of ty_s_log_read_write.
  data end of ds_method .
  class-data:
    dt_method like standard table of ds_method .

  methods CHANGE_TIME_IN_FILTER
    importing
      !YEAR type CLIKE
      !CV type UJK_T_CV
    changing
      !SEL type UJ0_T_SEL .
  methods HOR_TAB
    importing
      !IN type CLIKE
      !N type I
    returning
      value(OUT) type STRING .
  methods SEND_EMAIL
    importing
      !I_SEND type RS_BOOL default ABAP_FALSE
      !I_ERROR type RS_BOOL default ABAP_FALSE
    preferred parameter I_SEND .
  methods WRITE_LOG_PACK
    importing
      !MESSAGE type STRING
      !MODE type C .
  methods GET_LOG_TIME
    importing
      !START type TZNTSTMPL
      !END type TZNTSTMPL
      !MODE type I default 1
    returning
      value(RES) type STRING .
  methods GET_LOG_STAT
    importing
      !IS_RW_LOG type TY_S_LOG_READ_WRITE
    returning
      value(RES) type STRING .
  methods GET_LOG_ROWS
    importing
      !IS_RW_LOG type TY_S_LOG_READ_WRITE
    returning
      value(RES) type STRING .
  methods PRINT_LOG
    importing
      !PRINT_LOG type RS_BOOL .
  methods CUR_CONTEXT
    importing
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional .
  methods GET_T_PARAM
    importing
      !IT_PARAM type UJK_T_SCRIPT_LOGIC_HASHTABLE
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
    raising
      ZCX_RB_LOGISTICS .

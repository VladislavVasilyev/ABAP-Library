class ZCL_RB_RFC_TASK definition
  public
  final
  create public .

*"* public components of class ZCL_RB_RFC_TASK
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  types:
    ty_name_rfc_task type c length 8 .
  types:
    ty_type_task     type c length 1 .
  types:
    begin of ty_s_rfc_task
          , task         type ty_name_rfc_task
          , st           type c length 1
          , type         type c length 1
        , end of ty_s_rfc_task .
  types:
    begin of ty_s_rfc_rec_task
        , task           type ty_name_rfc_task
        , var            type ref to data
      , end of ty_s_rfc_rec_task .
  types:
    begin of ty_s_appl_write
         , appset_id type uj_appset_id
         , appl_id   type uj_appl_id
         , task      type ty_name_rfc_task
        , end of ty_s_appl_write .

  constants:
    begin of cs
         , rfc_run       type c length 1 value 'R'
         , rfc_free      type c length 1 value 'F'
         , rfc_read      type ty_type_task value 'R'
         , rfc_write     type ty_type_task value 'W'
        ,end   of cs .
  data NR_MAX_TASKS type I value 0 read-only. "#EC NOTEXT .

  methods WAIT_END_READ_TASK .
  methods GET_REF
    importing
      !TASK type TY_NAME_RFC_TASK
    returning
      value(REF) type ref to DATA .
  methods SET_TASK_FREE
    importing
      !TASK type TY_NAME_RFC_TASK .
  methods WAIT_END_ALL_TASK .
  methods GET_TASK_RUN
    importing
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !VAR type ref to DATA optional
    returning
      value(TASK) type TY_NAME_RFC_TASK .
  methods CONSTRUCTOR
    importing
      !NUM type I .

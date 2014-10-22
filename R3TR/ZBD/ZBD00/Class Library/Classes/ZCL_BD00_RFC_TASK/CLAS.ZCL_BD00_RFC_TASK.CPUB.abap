class ZCL_BD00_RFC_TASK definition
  public
  final
  create public .

*"* public components of class ZCL_BD00_RFC_TASK
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZBD0C .

  types:
    TY_MODE type c length 1 .
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

  class-methods CHECK_WAIT_FREE_TASKS .
  class-methods WHILE_TASK
    returning
      value(EXIT) type RS_BOOL
    raising
      ZCX_BD00_RFC_TASK .
  class-methods WAIT_END_READ_TASK .
  class-methods SET_TASK_FREE
    importing
      !TASK type TY_NAME_RFC_TASK .
  class-methods WAIT_END_ALL_TASK .
  type-pools ZBD0T .
  class-methods GET_TASK_RUN
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !MODE type C
    returning
      value(TASK) type ZBD0T_TY_NAME_RFC_TASK .
  methods CONSTRUCTOR
    importing
      !NUM type I
      !PARALLEL_TASK type RS_BOOL default ABAP_FALSE .

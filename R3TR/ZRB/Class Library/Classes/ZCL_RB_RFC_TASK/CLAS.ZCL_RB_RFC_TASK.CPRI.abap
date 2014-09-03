*"* private components of class ZCL_RB_RFC_TASK
*"* do not include other source files here!!!
private section.

  data:
    dt_rfc_process   type standard table of ty_s_rfc_task .
  data:
    dt_rfc_rec_task  type hashed table of ty_s_rfc_rec_task with unique key task .
  data:
    dt_appl_write    type hashed table of ty_s_appl_write with unique key appset_id appl_id .
  data NR_FREE_TASKS type I value 0. "#EC NOTEXT .
  data NR_USE_TASKS type I value 0. "#EC NOTEXT .
  data NR_READ_TASKS type I value 0. "#EC NOTEXT .
  data NR_WRITE_TASKS type I value 0. "#EC NOTEXT .

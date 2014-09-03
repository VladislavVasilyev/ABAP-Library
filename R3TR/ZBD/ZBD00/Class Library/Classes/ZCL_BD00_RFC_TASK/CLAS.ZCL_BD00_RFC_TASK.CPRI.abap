*"* private components of class ZCL_BD00_RFC_TASK
*"* do not include other source files here!!!
private section.

  class-data NR_MAX_TASKS type I value 0. "#EC NOTEXT .
  class-data:
    dt_rfc_process   type standard table of ty_s_rfc_task .
  class-data:
    dt_appl_write    type hashed table of ty_s_appl_write with unique key appset_id appl_id .
  class-data NR_FREE_TASKS type I value 0. "#EC NOTEXT .
  class-data NR_USE_TASKS type I value 0. "#EC NOTEXT .
  class-data NR_READ_TASKS type I value 0. "#EC NOTEXT .
  class-data NR_WRITE_TASKS type I value 0. "#EC NOTEXT .
  class-data DT_F_PARALLEL type RS_BOOL .

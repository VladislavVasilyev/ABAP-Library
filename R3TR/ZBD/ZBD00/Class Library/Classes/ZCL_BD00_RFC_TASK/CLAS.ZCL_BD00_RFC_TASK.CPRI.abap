*"* private components of class ZCL_BD00_RFC_TASK
*"* do not include other source files here!!!
private section.

  class-data nr_max_tasks type i value 0.                 "#EC NOTEXT .
  class-data:
    dt_rfc_process   type standard table of ty_s_rfc_task .
  class-data:
    dt_appl_write    type hashed table of ty_s_appl_write with unique key appset_id appl_id .
  class-data nr_free_tasks type i value 0.                "#EC NOTEXT .
  class-data nr_use_tasks type i value 0.                 "#EC NOTEXT .
  class-data nr_read_tasks type i value 0.                "#EC NOTEXT .
  class-data nr_write_tasks type i value 0.               "#EC NOTEXT .
  class-data dt_f_parallel type rs_bool .
  class-data cd_v__while_start type tzntstmpl .
  class-data nr_res_free_task type i .
  class-data cd_f__init type rs_bool .

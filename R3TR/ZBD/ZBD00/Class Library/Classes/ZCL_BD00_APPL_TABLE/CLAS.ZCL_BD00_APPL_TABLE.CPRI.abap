*"* private components of class ZCL_BD00_APPL_TABLE
*"* do not include other source files here!!!
private section.

  data gr_t__table     type ref to data .
  data gd_s__last_add  type ty_s_class_reg .
  data gd_s__last_read type ty_s_class_reg .
  data gr_o__process_data type ref to lcl_process_data .
*  class-data: cd_t__log_object type standard table of ref to lcl_log with non-unique default key.
  class-data: begin of cd_s__infocube
              , flag type rs_bool
              , name type rsinfoprov
              , kyf  type zbd0t_ty_t_kf
              , end of cd_s__infocube.

  class-data: begin of cd_s__appl_cust
              , flag type rs_bool
              , dimension type uj_dim_name
              , name type rsinfoprov
              , kyf  type zbd0t_ty_t_kf
              , end of cd_s__appl_cust.

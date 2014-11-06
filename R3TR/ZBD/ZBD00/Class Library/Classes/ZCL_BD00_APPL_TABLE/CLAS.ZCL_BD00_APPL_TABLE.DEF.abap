*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature
class lcl_process_data definition deferred.
class lcl_log definition deferred.
class zcl_bd00_appl_table definition local friends lcl_process_data.
class zcl_bd00_appl_table definition local friends lcl_log.
*----------------------------------------------------------------------*
*       CLASS cl_access_data DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_process_data
  definition final friends zcl_bd00_appl_table .
  public section.
    types ty_read_mode type c length 1.

    types: begin of ty_custom_appl
           , object type ref to zcl_bd00_appl_table
           , end of ty_custom_appl.

    constants begin of read_mode.
    constants pack type ty_read_mode value `1`.
    constants full type ty_read_mode value `2`.
    constants end   of read_mode.

    data go_log type ref to lcl_log.
    data gd_t__cust_appl type sorted table of ty_custom_appl with unique key object.

    methods
    : constructor
        importing io_appl_table     type ref to zcl_bd00_appl_table
                  it_range          type uj0_t_sel optional
                  iv_packagesize    type i optional
                  iv_destination    type string optional
                  if_suppress_zero  type rs_bool default abap_false
                  if_invert         type rs_bool default abap_false
    , read_data_arfc_receive
        importing !p_task type clike
        raising   zcx_bd00_read_data
    , write_data_arfc_receive
        importing p_task type clike
    , get_ref_range_table returning value(ref) type ref to data
    .

  private section.
    data
    : go_appl_table       type ref to zcl_bd00_appl_table
    , go_appl             type ref to zcl_bd00_application
    , gr_table            type ref to data
    , gt_range_tech_name  type rsdri_t_range
    , gt_range            type uj0_t_sel
    , gv_packagesize      type i
    , gf_first_call       type rs_bool value abap_true
    , gf_end_of_data      type rs_bool value abap_false
    , gt_message          type rs_t_msg
    , gf_arfc_read        type rs_bool
    , gf_suppress_zero    type rs_bool
*    , gt_suppress_zero    type zbd0t_ty_t_kf
    , gv_table_kind       type abap_tablekind
    , gt_alias            type zbd00_t_alias_rfc
    , gv_nr_pack_read     type i
    , gv_nr_pack_write    type i
    , gd_v__rule_assign   type zbd0t_id_rules
    , gd_f__gen_init      type rs_bool
    , gd_f__invert        type rs_bool
    , gd_v__destination   type rfcdest
    .

    methods
    : read_data_arfc
         returning value(e_eod) type rs_bool
         raising zcx_bd00_read_data
                 zcx_bd00_rfc_task
    , read_data_srfc
         returning value(e_eod) type rs_bool
         raising zcx_bd00_read_data
    , read_data
         importing mode type ty_read_mode
         returning value(e_st) type zbd0c_ty_read_st
         raising zcx_bd00_read_data
    , generate_data
         importing mode type ty_read_mode
         returning value(e_st) type zbd0c_ty_read_st
         raising zcx_bd00_read_data zcx_bd00_create_rule cx_static_check
    , generate_dimension
         returning value(e_st) type zbd0c_ty_read_st
         raising cx_static_check
    , loop
         importing index type i default 0
                   next_pack type rs_bool
                   packagesize type i
         returning value(e_pack) type rs_bool
         raising cx_dynamic_check cx_static_check
    , generate
         importing packagesize type i
                   next_pack type rs_bool
         exporting eod  type rs_bool
         raising cx_dynamic_check cx_static_check
    , next_line
         importing f_read type rs_bool
                   object type ref to zcl_bd00_appl_table
         returning value(e_st)  type zbd0c_ty_read_st
    , recieve_arfc for event ev_read_data_after_rfc_call of zcl_bd00_appl_table
    , write_data_arfc
         importing
          i_mode type zrb_write_back_mode default `A`
          raising zcx_bd00_rfc_task
    , get_range
         importing it_range type uj0_t_sel
    .
endclass.                    "cl_access_data DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_log DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_log definition final.

  public section.

    data gd_t__read           type zbd0t_t__log_read.       "#EC NEEDED
    data gd_t__read_dim       type zbd0t_t__log_dimension.  "#EC NEEDED
    data gd_t__write          type zbd0t_t__log_write.      "#EC NEEDED
    data gd_t__open_write     type zbd0t_t__log_write.      "#EC NEEDED
    data gd_t__num_rows       type zbd0t_t__log_actual.     "#EC NEEDED


    methods
    : set_read  importing read  type zbd0t_s__log_read
    , set_read_dim  importing read  type zbd0t_s__log_read
    , set_write importing write type zbd0t_s__log_write
    , set_actual importing actual_rows type i returning value(e) type i
    .

  private section.
    data gd_v__nr_actual type i.


endclass.                    "lcl_log DEFINITION

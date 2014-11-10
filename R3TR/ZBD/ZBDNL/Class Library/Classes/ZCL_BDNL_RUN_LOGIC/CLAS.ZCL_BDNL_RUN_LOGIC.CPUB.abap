*----------------------------------------------------------------------*
*       CLASS ZCL_BDNL_RUN_LOGIC  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zcl_bdnl_run_logic definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_RUN_LOGIC
*"* do not include other source files here!!!
  public section.
    type-pools abap .
    type-pools zbnlt .

    types:
      begin of ty_s__current_for
        , container type ref to zcl_bdnl_container
        , end of ty_s__current_for .
    types:
      ty_t__current_for type standard table of ty_s__current_for with non-unique default key .
    types:
      begin of  ty_s__rules
              , search type zbnlt_t__search
              , n_search type i
              , assign type zbnlt_t__assign
              , n_assign type i
              , assign_not_found type zbnlt_t__assign
              , n_assign_not_found type i
              , f_continue type rs_bool
              , end of ty_s__rules .

    types:
      begin of  ty_s__rulesnext
              , search type zbnlt_t__search
              , n_search type i
              , end of  ty_s__rulesnext.

    types:
      ty_t__rules type standard table of ty_s__rules with non-unique default key .

    data gd_s__rules type ty_s__rules .
    data gd_s__stack type zbnlt_s__stack .
    data gd_t__for_containers type zbnlt_t__containers .
    " data GD_T__FOR_CONTAINERS1 type TY_T__CURRENT_FOR .
    data gr_o__params type ref to zcl_bdnl_badi_params .
    class-data cd_t__searchmessage type standard table of string read-only.


    methods run
      raising
        zcx_bdnl_exception
        cx_static_check
        cx_dynamic_check .
    methods constructor
      importing
        !i_o__param type ref to zcl_bdnl_badi_params
        !i_f__rspc type rs_bool default abap_false
        !i_f__parallel_task type rs_bool default abap_false
        !i_v__num_tasks type i optional
      raising
        zcx_bdnl_exception .

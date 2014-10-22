*"* private components of class ZCL_BDNL_CONTAINER
*"* do not include other source files here!!!
private section.

  class-data cd_t__table_for type ty_t__reestr .
  class-data cd_t__table_reestr type ty_t__reestr .
  class-data cd_v__current_script type string .
  class-data cd_v__short_script type string .
  class-data cd_v__n_turn type i .
  class-data cd_v__n_for type i .
  class-data cd_v__n_script type i .
  class-data cr_s__log type ref to ty_s__log .
  data gd_s__param type zbnlt_s__stack_container .
  data gd_v__packagesize type i .
  data gd_v__script type string .
  data gd_v__turn type i .

  methods create__bpcgen
    importing
      !i_v__package_size type i
    returning
      value(e_f__create) type rs_bool .
  methods create__bpcdim
    returning
      value(e_f__create) type rs_bool .
  methods create__bpc
    importing
      !i_v__package_size type i
    returning
      value(e_f__create) type rs_bool .
  methods create__bp
    importing
      !i_v__package_size type i
    returning
      value(e_f__create) type rs_bool .
  methods create_tablefordown
    returning
      value(e_f__create) type rs_bool .
  methods create_ctable
    returning
      value(e_f__create) type rs_bool .
  methods create_clear
    returning
      value(e_f__create) type rs_bool .
  methods create_select
    importing
      !i_v__package_size type i
    returning
      value(e_f__create) type rs_bool .
  methods create_table
    importing
      !f_master type rs_bool
      !package_size type i .
  methods constructor
    importing
      !i_param type zbnlt_s__stack_container .

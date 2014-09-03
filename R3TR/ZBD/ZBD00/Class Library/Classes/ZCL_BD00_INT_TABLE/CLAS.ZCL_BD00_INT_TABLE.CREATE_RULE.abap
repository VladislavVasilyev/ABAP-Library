method create_rule.
  data
   : lo_class               type ref to zcl_bd00_int_table
   , lo_object              type ref to object
   , gv_type                type c length 1
   , lv_name_class          type string
   , lt_object_reestr       type ty_t_object_reestr


  , ld_t__rule_link                    type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
.

  ld_t__rule_link   = zcl_bd00_appl_ctrl=>get_key_link( id ) .


*  if io_key is bound and io_key is supplied.
*
  zcl_bd00_int_table_ctrl=>create_dyn_rule(
  exporting
    id               = id
  importing
    class            = lv_name_class
    et_object_reestr = lt_object_reestr ).

  create object lo_class
    type
      (lv_name_class)
    exporting
      it_rule_link     = ld_t__rule_link
      it_reestr       = lt_object_reestr.
*
*    set handler eo_class->change_fline for io_key activation 'X'.
*  else.
*    create object eo_class
*      type
*        zcl_bd00_int_table_ctrl
*      exporting
*        io_tg                   = io_tg.
*  endif.
*
*  set handler eo_class->change_table for io_tg activation 'X'.

  eo_class ?= lo_class.
endmethod.

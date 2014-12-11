method create_read.

  data
  : lo_class                type ref to zcl_bd00_int_table
  , lv_name_class           type string
  , lt_object_reestr        type ty_t_object_reestr
  , ld_t__rule_link         type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , ld_s__reestr_36         type ty_s__reestr_36
  .

  ld_t__rule_link   = zcl_bd00_appl_ctrl=>get_key_link( id ) .


  if ( ld_t__rule_link-id ne ld_t__rule_link-main->gd_v__default_rule  )."or ( signature-id is not initial ).

    if i_f__36 = abap_false.

      zcl_bd00_int_table_ctrl=>create_dyn_read(
      exporting
        id                = id
      importing
        class             = lv_name_class
        et_object_reestr  = lt_object_reestr ).

      create object lo_class
        type
          (lv_name_class)
        exporting
          it_rule_link    = ld_t__rule_link
          it_reestr       = lt_object_reestr.

      if ld_t__rule_link-default is bound.
        set handler lo_class->change_fline for ld_t__rule_link-default activation 'X'.
      endif.

    else.
      call method zcl_bd00_int_table_ctrl=>create_dyn_read
        exporting
          id               = id
          i_f__36          = abap_true
        importing
          class            = lv_name_class
          et_object_reestr = lt_object_reestr.

      ld_s__reestr_36-id = id.
      ld_s__reestr_36-class = lv_name_class.
      ld_s__reestr_36-t_object = lt_object_reestr.

      insert ld_s__reestr_36 into table cd_t__reestr_36.
    endif.
  else.
    create object lo_class
      type
        zcl_bd00_int_table_ctrl
      exporting
        it_rule_link            = ld_t__rule_link.

    set handler lo_class->delete_line for ld_t__rule_link-main activation 'X'.
  endif.

  if i_f__36 = abap_false.
    set handler lo_class->change_table for ld_t__rule_link-main activation 'X'.
    eo_class ?= lo_class.
  endif.

endmethod.

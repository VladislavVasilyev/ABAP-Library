method create_code_unique_key.

  data
  : lt_cust_link              type zcl_bd00_appl_ctrl=>ty_t_cust_link
  , ls_cust_link              type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , lt_range                  type zbd0t_ty_t_range_kf
  , lt_reestr_link            type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , ls_str                    type string
  , lt_tg_table_key           type abap_keydescr_tab
  , lt_sc_table_key           type abap_keydescr_tab
  , cnt                       type i value 0
  , lr_o_appl_ctrl            type ref to zcl_bd00_appl_ctrl
  , lv_end_line               type string
  , lt_field_symbols          type ty_t_string
  , lt_assign_symbols         type ty_t_string
  , lt_key                    type ty_t_string
  , ls_code_read              type string
  .

  field-symbols
  : <ls_link>	                type zcl_bd00_appl_ctrl=>ty_s_link
  , <ls_object_reestr>        type ty_s_object_reestr
  , <ls_tg_table_key>         type abap_keydescr
  , <ls_sc_table_key>         type abap_keydescr
  , <ls_definition>           type ty_s_definition
  , <ls_cust_link>            type zcl_bd00_appl_ctrl=>ty_s_cust_link
  .

  create_local_td(
  exporting
     it_object_reestr     = it_object_reestr
     it_rule_link         = it_rule_link
  importing
     et_field_symbols     = lt_field_symbols
     et_assign_symbols    = lt_assign_symbols ).


  clear cnt.

  loop at it_rule_link-rule_link
       assigning <ls_cust_link>.

    add 1 to cnt.

    move <ls_cust_link>-object ?to lr_o_appl_ctrl.

    if <ls_cust_link>-object   is bound.
      read table it_object_reestr
           with key object = lr_o_appl_ctrl
           assigning <ls_object_reestr>.

      if sy-subrc = 0.
        read table <ls_object_reestr>-definition
             with key id = id_code-field_st
             assigning <ls_definition>.

        concatenate <ls_cust_link>-tg ` = ` <ls_definition>-name `-` <ls_cust_link>-sc  into ls_str.
        translate ls_str to lower case.
      endif.

    elseif <ls_cust_link>-data is bound.
      read table it_object_reestr
           with key data = <ls_cust_link>-data
           assigning <ls_object_reestr>.

      if sy-subrc = 0.
        read table <ls_object_reestr>-definition
             with key id = id_code-field_st
             assigning <ls_definition>.

        concatenate <ls_cust_link>-tg ` = ` <ls_definition>-name  into ls_str.
        translate ls_str to lower case.
      endif.
    else.
      ls_str = <ls_cust_link>-tg.
      translate ls_str to lower case.
      concatenate ls_str ` = ` ```` <ls_cust_link>-const ````  into ls_str.
    endif.

    append ls_str to lt_key.
  endloop.

  read table it_object_reestr
       with key object = it_rule_link-main
       assigning <ls_object_reestr>.

  read table <ls_object_reestr>-definition
       with key id = id_code-field_tab
       assigning <ls_definition>.

  concatenate `read table ` <ls_definition>-name ` with table key`
       into  ls_code_read.


*╔═══════════════════════════════════════════════════════════════════╗
*║ Формирование текста программы                                     ║
*╠═══════════════════════════════════════════════════════════════════╣
  mac__append_to_itab et_code
  :`method next.`
  ,`data lr_s_result type ref to data.`
  .

  append lines of lt_field_symbols to et_code.

  mac__append_to_itab et_code
  :`if gv_index = 0.`
  .

  append lines of lt_assign_symbols   to et_code.
  append          ls_code_read        to et_code.
  append lines of lt_key              to et_code.

  mac__append_to_itab et_code
  :`reference into lr_s_result.`
  ,`if sy-subrc = 0.`
  ,`set_result( ir_result = lr_s_result ).`
  ,`e_st = zbd0c_found.`
  ,`else.`
  ,`e_st = zbd0c_not_found.`
  ,`endif.`
  ,`endif.`
  ,`endmethod.`
  .
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.

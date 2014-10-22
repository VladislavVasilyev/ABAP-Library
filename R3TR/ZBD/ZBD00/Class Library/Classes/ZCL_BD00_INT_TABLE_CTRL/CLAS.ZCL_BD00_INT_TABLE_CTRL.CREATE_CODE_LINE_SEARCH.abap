method CREATE_CODE_LINE_SEARCH.

  data
  : lt_cust_link              type zcl_bd00_appl_ctrl=>ty_t_cust_link
  , ls_cust_link              type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , lt_range                  type zbd0t_ty_t_range_kf
  , lt_reestr_link            type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , lt_tg_table_key           type abap_keydescr_tab
  , lt_sc_table_key           type abap_keydescr_tab
  , cnt                       type i value 0
  , lr_o_appl_ctrl            type ref to zcl_bd00_appl_ctrl
  , lv_end_line               type string
  , lt_field_symbols          type ty_t_string
  , lt_assign_symbols         type ty_t_string
  , lt_key                    type ty_t_string
  , ls_code_loop              type string
  .

  field-symbols
  : <ls_link>	                type zcl_bd00_appl_ctrl=>ty_s_link
  , <ls_object_reestr>        type ty_s_object_reestr
  , <ls_tg_table_key>         type abap_keydescr
  , <ls_sc_table_key>         type abap_keydescr
  , <ls_definition>           type ty_s_definition
  .

*break-point.

*  create_local_td(
*  exporting
*     it_object_reestr     = it_object_reestr
*     it_rule_link         = it_rule_link
*  importing
*     et_field_symbols     = lt_field_symbols
*     et_assign_symbols    = lt_assign_symbols ).


*  clear cnt.
*
*  loop at it_rule_link-rule_link
*       assigning is_rule_link.

*    add 1 to cnt.

    move is_rule_link-object ?to lr_o_appl_ctrl.

    if is_rule_link-object   is bound.
      read table it_object_reestr
           with key object = lr_o_appl_ctrl
           assigning <ls_object_reestr>.

      if sy-subrc = 0.
        read table <ls_object_reestr>-definition
             with key id = id_code-field_st
             assigning <ls_definition>.

        concatenate is_rule_link-tg ` = ` <ls_definition>-name `-` is_rule_link-sc  into ev_code.
        translate ev_code to lower case.
      endif.

    elseif is_rule_link-data is bound.
      read table it_object_reestr
           with key data = is_rule_link-data
           assigning <ls_object_reestr>.

      if sy-subrc = 0.
        read table <ls_object_reestr>-definition
             with key id = id_code-field_st
             assigning <ls_definition>.

        concatenate is_rule_link-tg ` = ` <ls_definition>-name  into ev_code.
        translate ev_code to lower case.
      endif.
    elseif is_rule_link-clear = abap_true.
      ev_code = is_rule_link-tg.
      translate ev_code to lower case.
      concatenate ev_code ` is initial`  into ev_code.
    else.
      ev_code = is_rule_link-tg.
      translate ev_code to lower case.
      concatenate ev_code ` = ` ```` is_rule_link-const ````  into ev_code.
    endif.

*    if cnt < lines( it_rule_link-rule_link ).
*      lv_end_line = ` and`.
*    else.
*      lv_end_line = `.`.
**      lv_end_line = ` and /cpmb/sdata in gt_range.`.
*    endif.
*
*
*    concatenate ev_code lv_end_line into ev_code.
*    append ev_code to lt_key.
*  endloop.
*
*  read table it_object_reestr
*       with key object = it_rule_link-main
*       assigning <ls_object_reestr>.
*
*  read table <ls_object_reestr>-definition
*       with key id = id_code-field_tab
*       assigning <ls_definition>.
*
*  concatenate `loop at ` <ls_definition>-name ` reference into lr_s_result where`
*       into  ls_code_loop.
*
*
**╔═══════════════════════════════════════════════════════════════════╗
**║ Формирование текста программы                                     ║
**╠═══════════════════════════════════════════════════════════════════╣
*  mac__append_to_itab et_code
*  :`method next.`
*  ,`data lr_s_result type ref to data.`
*  .
*
*  append lines of lt_field_symbols to et_code.
*
*  mac__append_to_itab et_code
*  :`if gv_index = 0.`
*  .
*
*  append lines of lt_assign_symbols   to et_code.
*  append          ls_code_loop        to et_code.
*  append lines of lt_key              to et_code.
*
*  mac__append_to_itab et_code
*  :`append lr_s_result to gt_result.`
*  ,`endloop.`
*  ,`endif.`
*  ,`e_st = next_line( ).`
*  ,`endmethod.`
  .
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.

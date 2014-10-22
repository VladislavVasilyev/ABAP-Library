method create_code_non_unique_key.

  data
  : lt_cust_link              type zcl_bd00_appl_ctrl=>ty_t_cust_link
  , ls_cust_link              type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , lt_range                  type zbd0t_ty_t_range_kf
  , lt_reestr_link            type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , ls_str                    type string
  , ls_str_or                 type string
  , lt_tg_table_key           type abap_keydescr_tab
  , lt_sc_table_key           type abap_keydescr_tab
  , cnt                       type i value 0
  , lr_o_appl_ctrl            type ref to zcl_bd00_appl_ctrl
  , lv_end_line               type string
  , lt_field_symbols          type ty_t_string
  , lt_assign_symbols         type ty_t_string
  , lt_key                    type ty_t_string
  , ls_code_loop              type string
  , ld_v__first_or            type i
  .

  field-symbols
  : <ls_link>	                type zcl_bd00_appl_ctrl=>ty_s_link
  , <ls_object_reestr>        type ty_s_object_reestr
  , <ls_tg_table_key>         type abap_keydescr
  , <ls_sc_table_key>         type abap_keydescr
  , <ls_definition>           type ty_s_definition
  , <ls_cust_link>            type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , <ls_cust_link_or>         type zcl_bd00_appl_ctrl=>ty_s_cust_link
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

    ls_str = create_code_line_search( is_rule_link = <ls_cust_link> it_object_reestr = it_object_reestr  ).

     clear ld_v__first_or.

    loop at it_rule_link-rule_link_or assigning <ls_cust_link_or>
      where tg = <ls_cust_link>-tg.

      add 1 to ld_v__first_or.

      if ld_v__first_or = 1.
        concatenate `( ` ls_str  into ls_str.
        append ls_str to lt_key.
      endif.

      ls_str_or = create_code_line_search( is_rule_link = <ls_cust_link_or> it_object_reestr = it_object_reestr  ).

      concatenate ` or ` ls_str_or into ls_str_or.
      append ls_str_or to lt_key.
    endloop.

    if ld_v__first_or > 0.
      ls_str = `) `.
    endif.

*    move <ls_cust_link>-object ?to lr_o_appl_ctrl.
*
*    if <ls_cust_link>-object   is bound.
*      read table it_object_reestr
*           with key object = lr_o_appl_ctrl
*           assigning <ls_object_reestr>.
*
*      if sy-subrc = 0.
*        read table <ls_object_reestr>-definition
*             with key id = id_code-field_st
*             assigning <ls_definition>.
*
*        concatenate <ls_cust_link>-tg ` = ` <ls_definition>-name `-` <ls_cust_link>-sc  into ls_str.
*        translate ls_str to lower case.
*      endif.
*
*    elseif <ls_cust_link>-data is bound.
*      read table it_object_reestr
*           with key data = <ls_cust_link>-data
*           assigning <ls_object_reestr>.
*
*      if sy-subrc = 0.
*        read table <ls_object_reestr>-definition
*             with key id = id_code-field_st
*             assigning <ls_definition>.
*
*        concatenate <ls_cust_link>-tg ` = ` <ls_definition>-name  into ls_str.
*        translate ls_str to lower case.
*      endif.
*    elseif <ls_cust_link>-clear = abap_true.
*      ls_str = <ls_cust_link>-tg.
*      translate ls_str to lower case.
*      concatenate ls_str ` is initial`  into ls_str.
*    else.
*      ls_str = <ls_cust_link>-tg.
*      translate ls_str to lower case.
*      concatenate ls_str ` = ` ```` <ls_cust_link>-const ````  into ls_str.
*    endif.

    if cnt < lines( it_rule_link-rule_link ).
      lv_end_line = ` and`.
    else.
      lv_end_line = `.`.
*      lv_end_line = ` and /cpmb/sdata in gt_range.`.
    endif.


    concatenate ls_str lv_end_line into ls_str.
    append ls_str to lt_key.
  endloop.

  read table it_object_reestr
       with key object = it_rule_link-main
       assigning <ls_object_reestr>.

  read table <ls_object_reestr>-definition
       with key id = id_code-field_tab
       assigning <ls_definition>.

  concatenate `loop at ` <ls_definition>-name ` reference into lr_s_result where`
       into  ls_code_loop.


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
  append          ls_code_loop        to et_code.
  append lines of lt_key              to et_code.

  mac__append_to_itab et_code
  :`append lr_s_result to gt_result.`
  ,`endloop.`
  ,`endif.`
  ,`e_st = next_line( ).`
  ,`endmethod.`
  .
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.

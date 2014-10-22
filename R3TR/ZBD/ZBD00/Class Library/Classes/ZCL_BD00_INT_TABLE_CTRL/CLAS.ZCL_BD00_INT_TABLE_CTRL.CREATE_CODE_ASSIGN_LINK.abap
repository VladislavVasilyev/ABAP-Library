method create_code_assign_link.

  data
  : ls_str                    type string
  , lr_o__appl_ctrl           type ref to zcl_bd00_appl_ctrl
  , lr_o__appl_table          type ref to zcl_bd00_appl_table
  , ld_t__field_symbols       type ty_t_string
  , ld_t__assign_symbols      type ty_t_string
  , ld_t__assign_list         type ty_t_string
  , ld_v__object_name         type string
  , ld_v__reference_name      type string
  , ld_v__type_name           type string
  , ld_v__table_name          type string
  , ld_v__name_sc_kf          type string
  , ld_v__name_tg_ch          type string
  , ld_v__name_sc_ch          type string
  , ld_v__regex               type string
  , ld_v__str_mcoresp         type string
  , ld_f__math_const          type rs_bool value abap_false
  , ld_t__mode_add            type ty_t_string
  , ld_v__idst                type ty_id_code
  .

  field-symbols
  : <ls_object_reestr>        type ty_s_object_reestr
  , <ls_definition>           type ty_s_definition
  , <ls_cust_link>            type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , <ld_s__assign_list>       type line of ty_t_string
  .

  create_local_td(
  exporting
     it_object_reestr         = it_object_reestr
     it_rule_link             = it_rule_link
     i_mode_add               = it_rule_link-mode_add
  importing
     et_field_symbols         = ld_t__field_symbols
     et_assign_symbols        = ld_t__assign_symbols ).

*--------------------------------------------------------------------*
* ld_v__object_name - field-symbols  строки целевой таблицы
  read table it_object_reestr
       with key object = it_rule_link-main
       assigning <ls_object_reestr>.

  ld_v__reference_name = <ls_object_reestr>-name.


  case it_rule_link-mode_add.
    when zbd0c_mode_add_line-change.
      read table <ls_object_reestr>-definition
           with key id = id_code-field_st
           assigning <ls_definition>.

      ld_v__object_name = <ls_definition>-name.
    when others.
      read table <ls_object_reestr>-definition
           with key id = id_code-field_cst
           assigning <ls_definition>.

      ld_v__object_name = <ls_definition>-name.
  endcase.


  read table <ls_object_reestr>-definition
     with key id = id_code-field_tab
     assigning <ls_definition>.

  ld_v__table_name = <ls_definition>-name.

  read table <ls_object_reestr>-definition
       with key id = id_code-type
       assigning <ls_definition>.

  ld_v__type_name = <ls_definition>-name.

*--------------------------------------------------------------------*

* Если  объект по умолчанию сама цель
  if it_rule_link-main = it_rule_link-default.

    read table <ls_object_reestr>-definition
         with key id = id_code-field_cst
         assigning <ls_definition>.

    ld_v__str_mcoresp = <ls_definition>-name.

    read table <ls_object_reestr>-definition
         with key id = id_code-field_st
         assigning <ls_definition>.

    concatenate ld_v__str_mcoresp ` = ` <ls_definition>-name `.` into ld_v__str_mcoresp.
  endif.

  loop at it_rule_link-rule_link
       assigning <ls_cust_link>.

    if <ls_cust_link>-tg is not initial.
      concatenate ld_v__object_name `-` <ls_cust_link>-tg into ld_v__name_tg_ch.
      translate ld_v__name_tg_ch to lower case.
    endif.

    if <ls_cust_link>-object is bound.
      move <ls_cust_link>-object ?to lr_o__appl_ctrl.

      read table it_object_reestr
           with key object = lr_o__appl_ctrl
           assigning <ls_object_reestr>.

      if <ls_cust_link>-object = it_rule_link-main.
        case it_rule_link-mode_add.
          when zbd0c_mode_add_line-change.
            ld_v__idst = id_code-field_st.
          when others.
            ld_v__idst = id_code-field_cst.
        endcase.
      else.
        ld_v__idst = id_code-field_st.
      endif.

      read table <ls_object_reestr>-definition
           with key id = ld_v__idst
           assigning <ls_definition>.

      if <ls_cust_link>-sc is not initial.
        concatenate <ls_definition>-name `-` <ls_cust_link>-sc into ld_v__name_sc_ch.
        translate ld_v__name_sc_ch to lower case.
      elseif <ls_cust_link>-op is not initial.
        if <ls_cust_link>-kyf is not initial.
          ld_v__name_sc_kf = <ls_cust_link>-kyf.
          concatenate <ls_definition>-name `-` ld_v__name_sc_kf into ld_v__name_sc_kf.
          translate ld_v__name_sc_kf to lower case.
        else.
          if lines( lr_o__appl_ctrl->gr_o__model->gd_t__signeddata ) = 1.
            ld_v__name_sc_kf = lr_o__appl_ctrl->gr_o__model->gd_v__signeddata.
            concatenate <ls_definition>-name `-` ld_v__name_sc_kf into ld_v__name_sc_kf.
            translate ld_v__name_sc_kf to lower case.
          endif.
        endif.
      endif.

    elseif <ls_cust_link>-data is bound.
      read table it_object_reestr
           with key data = <ls_cust_link>-data
           assigning <ls_object_reestr>.

      read table <ls_object_reestr>-definition
           with key id = id_code-field_st
           assigning <ls_definition>.

      if <ls_cust_link>-tg is not initial.
        ld_v__name_sc_ch = <ls_definition>-name.
      elseif <ls_cust_link>-op is not initial.
        ld_v__name_sc_kf = <ls_definition>-name.
      endif.
    elseif <ls_cust_link>-const is not initial.
      if <ls_cust_link>-tg is not initial and
         <ls_cust_link>-tg <> it_rule_link-main->gr_o__model->gd_v__signeddata.
        concatenate ```` <ls_cust_link>-const ```` into ld_v__name_sc_ch.
      else.
        ld_v__name_sc_ch = <ls_cust_link>-const.
      endif.
    elseif <ls_cust_link>-clear = abap_true.
      ld_v__name_sc_ch = `space`.
    endif.

    if <ls_cust_link>-tg is not initial.
      if <ls_cust_link>-clear = abap_true.
        concatenate `clear ` ld_v__name_tg_ch `.` into ls_str.
      else.
        concatenate ld_v__name_tg_ch ` = ` ld_v__name_sc_ch `.` into ls_str.
      endif.
      if <ls_cust_link>-tg = it_rule_link-main->gr_o__model->gd_v__signeddata.
        append ls_str to ld_t__assign_list assigning <ld_s__assign_list>.
        if <ls_cust_link>-const is not initial.
          ld_f__math_const = abap_true.
        endif.
      else.
        append ls_str to ld_t__assign_list.
      endif.
    elseif <ls_cust_link>-op is not initial.
      concatenate `\<` <ls_cust_link>-op `\>` into ld_v__regex.
      replace all occurrences of regex ld_v__regex  in <ld_s__assign_list> with ld_v__name_sc_kf ignoring case.
    endif.
  endloop.

* Расчет показателя
  if ld_f__math_const = abap_true and <ld_s__assign_list> is assigned.
*    replace all occurrences of regex `(\<\d+((\-|\>)|\.\d{0,}(\-|\>)))` in <ld_s__assign_list> with ```$0```.
    replace all occurrences of regex `(\-\d+|\<\d+)(\>|\.\d+\>)` in <ld_s__assign_list> with ```$0```.
  endif.

*╔═══════════════════════════════════════════════════════════════════╗
*║ Правило вставки                                                   ║
*╠═══════════════════════════════════════════════════════════════════╣
  if it_rule_link-mode_add is not initial and not it_rule_link-mode_add = zbd0c_mode_add_line-change.
    concatenate `data lr_s_line type ref to ` ld_v__type_name `.` into ls_str.
    append ls_str to ld_t__mode_add.

    case it_rule_link-mode_add.
      when zbd0c_mode_add_line-collect.
        concatenate `collect ` ld_v__object_name ` into ` ld_v__table_name ` reference into lr_s_line.` into ls_str.
      when zbd0c_mode_add_line-insert.
        concatenate `insert ` ld_v__object_name ` into table ` ld_v__table_name ` reference into lr_s_line.` into ls_str.
      when zbd0c_mode_add_line-append.
        concatenate `append ` ld_v__object_name ` into ` ld_v__table_name ` reference into lr_s_line.` into ls_str.
    endcase.
    append ls_str to ld_t__mode_add.
    append `set_result( lr_s_line ).` to ld_t__mode_add.

    lr_o__appl_table ?= it_rule_link-main.

    if lr_o__appl_table->gd_f__auto_save = abap_true.

      concatenate `data size type i. size = lines( ` ld_v__table_name  ` ).` into ls_str.
      append ls_str to ld_t__mode_add.
      concatenate ld_v__reference_name `->auto_write_back( size ).` into ls_str.
      append ls_str to ld_t__mode_add.
    endif.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝

*╔═══════════════════════════════════════════════════════════════════╗
*║ Формирование текста программы                                     ║
*╠═══════════════════════════════════════════════════════════════════╣
  mac__append_to_itab et_code
  :`method rule.`
  .

  append lines of ld_t__field_symbols           to et_code.
  append lines of ld_t__assign_symbols          to et_code.

  if ld_v__str_mcoresp is not initial.
    append ld_v__str_mcoresp to et_code.
  endif.

  append lines of
  : ld_t__assign_list             to et_code
  , ld_t__mode_add                to et_code.

  mac__append_to_itab et_code
  :`endmethod.`
  .
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.

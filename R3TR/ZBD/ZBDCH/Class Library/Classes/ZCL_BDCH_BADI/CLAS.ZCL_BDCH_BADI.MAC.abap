*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
define mac__append_to_uj0_t_sel.
  ds_sel-sign       = &2.
  ds_sel-option     = &3.
  ds_sel-dimension  = &4.
  ds_sel-attribute  = &5.
  ds_sel-low        = &6.
*  ds_sel-high       = &7.
  append ds_sel to &1.
end-of-definition.

define mac__change_field.
  set_sf(
    exporting
      fn   = &2
      val  = &3
    changing
      st = &1 ).
end-of-definition.
define mac__write_to_tab.
  write_tab(
       exporting st   = &2
                 mode = &1
       changing  tab  = &3 ).
end-of-definition.
define mac__math_op.
  math( exporting arg1 = &2 o = &3 arg2 = &4 changing res = &1 ).
end-of-definition.
define mac__copy_st.
  copy_s(
       exporting sc = &1
       changing  tg = &2 ).
end-of-definition.
define mac__setting_clear.
  clear
    : dt_sel
    , dt_attr_list
    , dt_key_field
    , dt_dim_field
    , dt_insert_dim
    .
end-of-definition.
define mac__clear_table.
  clear( changing in = &1 ).
end-of-definition.
define mac__get_field.
  &3 = get_sf( st = &1 fn = &2 ).
end-of-definition.
define mac__add_dim.
  append &1 to dt_dim_field.
end-of-definition.
define mac__add_key.
  append &1 to dt_key_field.
end-of-definition.
define mac__add_attr.
  append &1 to dt_attr_list.
end-of-definition.
define mac__create_table.
  &4 = get_table_ref(
                   i_appset_id = &1
                   i_appl_id   = &2
                   i_type      = &3 ).
end-of-definition.
define mac__raise_logistics.
  raise exception type zcx_bdch_badi
        exporting textid = zcx_bdch_badi=>&1
                  arg1   = &2
                  arg2   = &3
                  arg3   = &4
                  arg4   = &5.
end-of-definition.
define mac__append_to_dim_list.
  ls_dim_list-dimension   = &1.
  ls_dim_list-attribute   = &2.
  ls_dim_list-f_key       = &3.
  ls_dim_list-orderby     = &4.
  insert ls_dim_list into table lt_dim_list.
end-of-definition.

define mac__add_key_link.
   clear ls_link.
  ls_link-tg-dimension = &1.
  ls_link-tg-attribute = &2.
  ls_link-sc-dimension = &3.
  ls_link-sc-attribute = &4.
  insert ls_link into table lt_link.
end-of-definition.

define mac__add_all_const.
  ls_const-dimension    = &1.
  ls_const-attribute    = &2.
  ls_const-const        = &3.
  insert ls_const into table lt_const.
end-of-definition.

define mac__add_rule_field_for_data.
  clear ls_rules_field.
  ls_rules_field-tg-dimension = &1.
  ls_rules_field-tg-attribute = &2.
  get reference of &3 into ls_rules_field-sc-data.
  insert ls_rules_field into table lt_rules_field.
end-of-definition.
define mac__add_rule_field_for_object.
  clear ls_rules_field.
  ls_rules_field-tg-dimension = &1.
  ls_rules_field-tg-attribute = &2.
  ls_rules_field-sc-dimension = &4.
  ls_rules_field-sc-attribute = &5.
  ls_rules_field-sc-object ?= &3.
  insert ls_rules_field into table lt_rules_field.
end-of-definition.
define mac__add_rule_field_for_const.
  clear ls_rules_field.
  ls_rules_field-tg-dimension = &1.
  ls_rules_field-tg-attribute = &2.
  ls_rules_field-sc-const     = &3.
  insert ls_rules_field into table lt_rules_field.
end-of-definition.
define mac__set_math_operand_object.
  clear ls_operand.
  ls_operand-var = &1.
  ls_operand-object = &2.
  insert ls_operand into table ls_rules_math-operand.
end-of-definition.
define mac__set_math_operand_data.
  clear ls_operand.
  ls_operand-var = &1.
  get reference of &2 into ls_operand-data.
  insert ls_operand into table ls_rules_math-operand.
end-of-definition.
define mac__set_math_operand_const.
  clear ls_operand.
  ls_operand-var = &1.
  ls_operand-const = &2.
  insert ls_operand into table ls_rules_math-operand.
end-of-definition.
define mac__clear_appl.
    create object &1
      exporting
        it_range     = &2
        i_type_pk    = zbd0c_ty_tab-std_non_unique_dk.

    while &1->next_pack( zbd0c_read_mode-pack ) eq zbd0c_read_pack .
      while &1->next_line( ) eq zbd0c_found.
        &1->math( signeddata = -1 operation = `MUL` ).
      endwhile.
    &1->write_back( ).
    endwhile.
    zcl_bd00_appl_table=>free_all_object( ).
end-of-definition.

define mac__ch_time.
  change_time_in_filter( exporting year = &1 cv = it_cv changing sel = &2 ).
end-of-definition.

define mac__insert_alias.
      clear: ld_s__alias.
      ld_s__alias-bpc_name-dimension  = &1.
      ld_s__alias-bpc_name-attribute  = &2.
      ld_s__alias-bpc_alias-dimension = &3.
      ld_s__alias-bpc_alias-attribute = &4.
      insert ld_s__alias into table ld_t__alias.

end-of-definition.

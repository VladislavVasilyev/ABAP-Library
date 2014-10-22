method create_rule_link_fields.

  data
  : ld_t__rules_field           type zbd0t_ty_t_rule_field
  , ld_t__rules_field1          type zbd0t_ty_t_custom_link1
  , ld_s__rules_field           type zbd0t_ty_s_rule_field
  , lr_o__target                type ref to zcl_bdnl_container
  , lr_o__source                type ref to zcl_bdnl_container
  , ld_s__search                type zbnlt_s__search
  , ld_s__reestr_link           type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , ld_t__function              type zbnlt_t__function
  , ld_s__function              type zbnlt_s__function
  , ld_s__dimension             type zbd0t_ty_s_dim
  , ld_v__message               type string
  , ld_v__cnt                   type i
  , ld_f__notfullkey            type rs_bool
  , ld_v__number_rules          type i
  .

  field-symbols
  : <ld_s__search>              type zbnlt_s__stack_search
  , <ld_s__rules>               type zbnlt_s__for_rules
  , <ld_s__link>                type zbnlt_s__cust_link
  , <ld_s__rule_link>           type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , <ld_v__key>                 type abap_keydescr
  .


  loop at i_t__link
       assigning <ld_s__link>.

    clear ld_s__rules_field.

    if <ld_s__link>-tablename is not initial.

      lr_o__source ?= zcl_bdnl_container=>create_container( <ld_s__link>-tablename ).

      ld_s__rules_field-tg           = <ld_s__link>-tg.
      ld_s__rules_field-sc-dimension = <ld_s__link>-sc-dimension.
      ld_s__rules_field-sc-attribute = <ld_s__link>-sc-attribute.
      ld_s__rules_field-sc-object    = lr_o__source->gr_o__container.

      append ld_s__rules_field to e_t__rule_link.
    elseif <ld_s__link>-const is not initial.
      ld_s__rules_field-tg           = <ld_s__link>-tg.
      ld_s__rules_field-sc-const     = <ld_s__link>-const.
      append ld_s__rules_field to e_t__rule_link.
    elseif <ld_s__link>-data is bound.
      ld_s__rules_field-tg           = <ld_s__link>-tg.
      ld_s__rules_field-sc-data      = <ld_s__link>-data.

      call method assign_function
        exporting
          i_s__function = <ld_s__link>
          i_v__turn     = i_s__for-turn
          i_s__for      = i_s__for
        importing
          e_t__function = ld_t__function.

      append lines of ld_t__function to e_t__function.
      append ld_s__rules_field to e_t__rule_link.
      clear ld_t__function.

      insert ld_s__rules_field into table ld_t__rules_field.
    elseif <ld_s__link>-clear = abap_true.
      ld_s__rules_field-tg           = <ld_s__link>-tg.
      ld_s__rules_field-sc-clear     = abap_true.
      append ld_s__rules_field to e_t__rule_link.
    endif.
  endloop.

endmethod.

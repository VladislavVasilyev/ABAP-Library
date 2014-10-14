method CREATE_SEARCH_RULE__________ST.

  data
  : ld_t__rules_field           type zbd0t_ty_t_rule_field
  , ld_s__rules_field           type zbd0t_ty_s_rule_field
  , ld_s__search                type zbnlt_s__search
  , ld_s__reestr_link           type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , lr_s__tg_containers         type ref to zbnlt_s__containers
  , lr_s__sc_containers         type ref to zbnlt_s__containers
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
  , <ld_s__tg_containers>       type zbnlt_s__containers
  , <ld_s__sc_containers>       type zbnlt_s__containers
  , <ld_s__rule_link>           type zcl_bd00_appl_ctrl=>ty_s_cust_link
  , <ld_v__key>                 type abap_keydescr
  .

  read table i_s__for-rules
       index i_v__turn
       assigning <ld_s__rules>.

  check sy-subrc = 0.

  loop at <ld_s__rules>-search assigning <ld_s__search>.
    add 1 to ld_v__number_rules.

   clear
   : ld_t__rules_field
   , ld_s__rules_field.

    lr_s__tg_containers = create_container( i_v__tablename = <ld_s__search>-tablename i_s__for = i_s__for ).
    assign lr_s__tg_containers->* to <ld_s__tg_containers>.

    message s033(zbdnl) with ld_v__number_rules <ld_s__search>-tablename <ld_s__tg_containers>-type_table.

    if <ld_s__search>-link is not initial.

      loop at <ld_s__search>-link
           assigning <ld_s__link>.

        clear ld_s__rules_field.

        if <ld_s__link>-tablename is not initial.

          lr_s__sc_containers = create_container( i_v__tablename = <ld_s__link>-tablename i_s__for = i_s__for ).
          assign lr_s__sc_containers->* to <ld_s__sc_containers>.

          ld_s__rules_field-tg           = <ld_s__link>-tg.
          ld_s__rules_field-sc-dimension = <ld_s__link>-sc-dimension.
          ld_s__rules_field-sc-attribute = <ld_s__link>-sc-attribute.
          ld_s__rules_field-sc-object    = <ld_s__sc_containers>-object.

          insert ld_s__rules_field into table ld_t__rules_field.
        elseif <ld_s__link>-const is not initial.
          ld_s__rules_field-tg           = <ld_s__link>-tg.
          ld_s__rules_field-sc-const     = <ld_s__link>-const.
          insert ld_s__rules_field into table ld_t__rules_field.
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

          append lines of ld_t__function to ld_s__search-function.
          clear ld_t__function.

          insert ld_s__rules_field into table ld_t__rules_field.
        endif.
      endloop.

      ld_s__search-tablename = <ld_s__search>-tablename.
      ld_s__search-id        = <ld_s__tg_containers>-object->set_rule_search( it_cust_link = ld_t__rules_field ).
      ld_s__search-object    = <ld_s__tg_containers>-object.

      read table zcl_bd00_appl_ctrl=>gd_t__reestr_link
           with table key id = ld_s__search-id
           into ld_s__reestr_link.

      ld_s__search-f_uk = ld_s__reestr_link-f_unique_key.

    elseif <ld_s__search>-default is not initial.

      lr_s__sc_containers = create_container( i_v__tablename = <ld_s__search>-default i_s__for = i_s__for ).
      assign lr_s__sc_containers->* to <ld_s__sc_containers>.

      ld_s__search-tablename = <ld_s__search>-tablename.
      ld_s__search-object    = <ld_s__tg_containers>-object.
      ld_s__search-id = <ld_s__tg_containers>-object->set_rule_search( io_default = <ld_s__sc_containers>-object ).

      read table zcl_bd00_appl_ctrl=>gd_t__reestr_link
           with table key id = ld_s__search-id
           into ld_s__reestr_link.

      ld_s__search-f_uk = ld_s__reestr_link-f_unique_key.

    endif.


*--------------------------------------------------------------------*
* MESSAGE
*--------------------------------------------------------------------*
    clear
    : ld_v__cnt
    , ld_v__message
    .

    loop at ld_s__reestr_link-rule_link assigning <ld_s__rule_link>.
      add 1 to ld_v__cnt.
      ld_s__dimension = <ld_s__tg_containers>-object->gr_o__model->get_dim_name( <ld_s__rule_link>-tg ).
      if ld_v__cnt = 1.
        if ld_s__dimension-attribute is initial.
          ld_v__message = ld_s__dimension-dimension.
        else.
          concatenate ld_s__dimension-dimension `~` ld_s__dimension-attribute into ld_v__message.
        endif.
      else.
        if ld_s__dimension-attribute is initial.
          concatenate ld_v__message ` ` ld_s__dimension-dimension into ld_v__message.
        else.
          concatenate ld_v__message ` ` ld_s__dimension-dimension `~` ld_s__dimension-attribute into ld_v__message.
        endif.
      endif.
    endloop.

    if ld_s__search-f_uk = abap_true.
      message s041(zbdnl) with ld_v__message. "Unique key. Optimal reading.
    else.
      if <ld_s__tg_containers>-type_table = zblnc_keyword-standard or
         <ld_s__tg_containers>-type_table = zblnc_keyword-hashed.
        message s042(zbdnl) with ld_v__message. "Not Unique key. Not optimal reading.
      elseif <ld_s__tg_containers>-type_table = zblnc_keyword-sorted.
        ld_f__notfullkey = abap_false.
        loop at <ld_s__tg_containers>-object->gr_o__model->gd_t__key assigning <ld_v__key>.
          read table ld_s__reestr_link-rule_link
               with key tg = <ld_v__key>
               transporting no fields.
          if sy-subrc <> 0.
            ld_f__notfullkey = abap_true.
          endif.
        endloop.

        case <ld_s__tg_containers>-object->gr_o__model->gd_v__type_pk.
          when zbd0c_ty_tab-srd_unique_dk.
           message s043(zbdnl) with ld_v__message. "Not Full Unique key. Not optimal reading.
          when zbd0c_ty_tab-srd_non_unique.
            if ld_f__notfullkey = abap_true.
              message s044(zbdnl) with ld_v__message. "Not Full not Unique key. Not optimal reading.
            else.
              message s045(zbdnl) with ld_v__message."Full not Unique key. Optimal reading.
            endif.
        endcase.
      endif.
    endif.
*--------------------------------------------------------------------*

    ld_s__search-class = zcl_bd00_appl_ctrl=>get_rule_class( ld_s__search-id ).
    append ld_s__search to e_t__search.

  endloop.

endmethod.
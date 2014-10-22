method set_rule_search.
*╔═══════════════════════════════════════════════════════════════════╗
*║ Регистрация соответствия ключей                                   ║
*║    Входные параметры:                                             ║
*║    ID      - идендификатор правила                                ║
*║    I_OBJ   - ссылка на объект для которого нужно проставить       ║
*║              соответсвие ключей                                   ║
*║    IT_LINK - таблица соответсвия                                  ║
*╠═══════════════════════════════════════════════════════════════════╣
  data
  : ld_s__link_reestr            type ty_s_rules_reestr
  , ld_s__cust_link              type ty_s_cust_link
  , ld_s__class_reg              type ty_s_class_reg
  , ld_t__cust_link              type ty_t_cust_link
  , ld_t__cust_link_or           type ty_t_cust_link_or
  , ld_t__tg_table_key           type abap_keydescr_tab
  , ld_t__sc_table_key           type abap_keydescr_tab
  , ld_v__tg_table_kind          type abap_tablekind
  , ld_v__cnt                    type i value 0
  , ld_f__tg_has_unique_key      type abap_bool
  , lr_o__link_object            type ref to zcl_bd00_appl_ctrl
  .

  field-symbols
  : <ld_s__link>                 type zbd0t_ty_s_link_key
  , <ld_s__i_cust_link>          type zbd0t_ty_s_custom_link
  , <ld_s__cust_link>            type ty_s_cust_link
  , <ld_s__tg_table_key>         type abap_keydescr
  , <ld_s__sc_table_key>         type abap_keydescr
  , <ld_t__dimension>            type zcl_bd00_model=>ty_t_dim_list
  .

  ld_s__link_reestr-id                = e_id = get_rule_id( ).
  ld_s__link_reestr-type              = zcl_bd00_int_table=>method-search.
  ld_s__link_reestr-main             ?= me.
  ld_s__link_reestr-default          ?= io_default.

  read table gd_t__reestr_link
       with table key id = ld_s__link_reestr-id
       transporting no fields.

  check sy-subrc <> 0.

  ld_t__tg_table_key      = gr_o__model->gd_t__key.
  ld_v__tg_table_kind     = gr_o__model->gd_s__handle-tab-tech_name->table_kind.
  ld_f__tg_has_unique_key = gr_o__model->gd_s__handle-tab-tech_name->has_unique_key.

  if io_default is bound.
    ld_t__sc_table_key = io_default->gr_o__model->gd_s__handle-tab-tech_name->key.

    assign gr_o__model->gr_t__dimension->* to <ld_t__dimension>.

    if it_link is initial.
      loop at ld_t__tg_table_key
           assigning <ld_s__tg_table_key>.

        read table ld_t__sc_table_key
             with table key table_line = <ld_s__tg_table_key>
             assigning <ld_s__sc_table_key>.

        check sy-subrc = 0.
        clear ld_s__cust_link.

        ld_s__cust_link-tg       = <ld_s__tg_table_key>.
        ld_s__cust_link-sc       = <ld_s__sc_table_key>.
        ld_s__cust_link-object   = io_default.
        insert ld_s__cust_link into table ld_t__cust_link.
      endloop.
    else.
      loop at it_link
           assigning <ld_s__link>.

        ld_s__cust_link-tg = gr_o__model->get_tech_alias(
                                dimension = <ld_s__link>-tg-dimension
                                attribute = <ld_s__link>-tg-attribute ).

        ld_s__cust_link-sc = io_default->gr_o__model->get_tech_alias(
                                dimension = <ld_s__link>-sc-dimension
                                attribute = <ld_s__link>-sc-attribute ).

        ld_s__cust_link-object = io_default.
        insert ld_s__cust_link into table ld_t__cust_link.
        clear ld_s__cust_link.
      endloop.
    endif.
  endif.

  if it_cust_link is not initial.
    loop at it_cust_link
         assigning <ld_s__i_cust_link>.

      ld_s__cust_link-tg = gr_o__model->get_tech_alias(
                              dimension = <ld_s__i_cust_link>-tg-dimension
                              attribute = <ld_s__i_cust_link>-tg-attribute ).

      lr_o__link_object ?= <ld_s__i_cust_link>-sc-object.

      if lr_o__link_object is bound.
        ld_s__cust_link-sc = lr_o__link_object->gr_o__model->get_tech_alias(
                                dimension = <ld_s__i_cust_link>-sc-dimension
                                attribute = <ld_s__i_cust_link>-sc-attribute ).
      endif.

      ld_s__cust_link-data    = <ld_s__i_cust_link>-sc-data.
      ld_s__cust_link-object ?= <ld_s__i_cust_link>-sc-object.
      ld_s__cust_link-const   = <ld_s__i_cust_link>-sc-const.
      ld_s__cust_link-clear   = <ld_s__i_cust_link>-sc-clear.

      modify table ld_t__cust_link from ld_s__cust_link.

      check sy-subrc ne 0.
      insert ld_s__cust_link into table ld_t__cust_link.

    endloop.
  elseif it_cust_link1 is not initial.
    loop at it_cust_link1
         assigning <ld_s__i_cust_link>.

      ld_s__cust_link-tg = gr_o__model->get_tech_alias(
                              dimension = <ld_s__i_cust_link>-tg-dimension
                              attribute = <ld_s__i_cust_link>-tg-attribute ).

      lr_o__link_object ?= <ld_s__i_cust_link>-sc-object.

      if lr_o__link_object is bound.
        ld_s__cust_link-sc = lr_o__link_object->gr_o__model->get_tech_alias(
                                dimension = <ld_s__i_cust_link>-sc-dimension
                                attribute = <ld_s__i_cust_link>-sc-attribute ).
      endif.

      ld_s__cust_link-data    = <ld_s__i_cust_link>-sc-data.
      ld_s__cust_link-object ?= <ld_s__i_cust_link>-sc-object.
      ld_s__cust_link-const   = <ld_s__i_cust_link>-sc-const.
      ld_s__cust_link-clear   = <ld_s__i_cust_link>-sc-clear.

      insert ld_s__cust_link into table ld_t__cust_link.

      check sy-subrc ne 0.
      append ld_s__cust_link to  ld_t__cust_link_or.

    endloop.
  endif.

  loop at ld_t__cust_link
       assigning <ld_s__cust_link>.

    read table ld_t__tg_table_key
         with key table_line = <ld_s__cust_link>-tg
         transporting no fields.

    if sy-subrc = 0.
      add 1 to ld_v__cnt.

      case ld_v__tg_table_kind.
        when cl_abap_tabledescr=>tablekind_std.
        when cl_abap_tabledescr=>tablekind_sorted.
          if ld_f__tg_has_unique_key = abap_true.
            <ld_s__cust_link>-f_key = abap_true.
          endif.
        when cl_abap_tabledescr=>tablekind_hashed.
          <ld_s__cust_link>-f_key = abap_true.
      endcase.
    endif.
  endloop.

  if ld_v__cnt => lines( ld_t__tg_table_key ).
    case ld_v__tg_table_kind.
      when cl_abap_tabledescr=>tablekind_std.
      when cl_abap_tabledescr=>tablekind_sorted.
        if ld_f__tg_has_unique_key = abap_true.
          ld_s__link_reestr-f_unique_key = abap_true.
        endif.
      when cl_abap_tabledescr=>tablekind_hashed.
        ld_s__link_reestr-f_unique_key = abap_true.
    endcase.
  endif.

  ld_s__link_reestr-rule_link = ld_t__cust_link.
  ld_s__link_reestr-rule_link_or = ld_t__cust_link_or.
  insert ld_s__link_reestr into table gd_t__reestr_link.

  ld_s__class_reg-id         = e_id.
  ld_s__class_reg-main      ?= me.
  ld_s__class_reg-class      = zcl_bd00_int_table=>create_read( e_id ).
  insert ld_s__class_reg into table gd_t__class_reg.

endmethod.

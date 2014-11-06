method set_rule_assign.

  data
*  : ld_s__rule_math         type ty_s_rule_math
  : ld_s__rule_reestr       type ty_s_rules_reestr
  , ld_s__cust_link         type ty_s_cust_link
  , ld_s__class_reg         type ty_s_class_reg
  , ld_t__cust_link         type ty_t_cust_link
  , lr_o__appl_ctrl         type ref to zcl_bd00_appl_ctrl
  , lr_o__appl_ctrl_kyf     type ref to zcl_bd00_appl_ctrl
  .

  field-symbols
  : <ld_s__rule_operand>    type zbd0t_ty_s_math_operand
  , <ld_s__tg_components>   type abap_keydescr
  , <ld_s__sc_components>   type abap_keydescr
  , <ld_s__link>            type zbd0t_ty_s_link_key
  , <ld_s__i_cust_link>     type zbd0t_ty_s_custom_link
  , <ld_s__cust_link>       type ty_s_cust_link
  , <ld_s__const>           type ty_s_const
  .

*╔═══════════════════════════════════════════════════════════════════╗
*║ Обработчик правил для признаков                                   ║
*╠═══════════════════════════════════════════════════════════════════╣
  ld_s__rule_reestr-id                 = e_id = get_rule_id( ).
  ld_s__rule_reestr-type               = zcl_bd00_int_table=>method-assign.
  ld_s__rule_reestr-main              = me.
  ld_s__rule_reestr-default           = io_default.

  read table gd_t__reestr_link
       with table key id = ld_s__rule_reestr-id
       transporting no fields.

  check sy-subrc <> 0.

  if io_default is bound and me ne io_default.
    if it_link is initial.
      loop at gr_o__model->gd_t__components
           assigning <ld_s__tg_components>.

        read table io_default->gr_o__model->gd_t__components "#EC *
             with table key name = <ld_s__tg_components>
             assigning <ld_s__sc_components>.

        check sy-subrc = 0.
        clear ld_s__cust_link.

        ld_s__cust_link-tg       = <ld_s__tg_components>.
        ld_s__cust_link-sc       = <ld_s__sc_components>.
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

  if it_field is not initial.
    loop at it_field
         assigning <ld_s__i_cust_link>.

      clear ld_s__cust_link.
      ld_s__cust_link-tg = gr_o__model->get_tech_alias(
                              dimension = <ld_s__i_cust_link>-tg-dimension
                              attribute = <ld_s__i_cust_link>-tg-attribute ).

      if <ld_s__i_cust_link>-sc-object is bound.

        move <ld_s__i_cust_link>-sc-object ?to lr_o__appl_ctrl.

        ld_s__cust_link-sc = lr_o__appl_ctrl->gr_o__model->get_tech_alias(
                                  dimension = <ld_s__i_cust_link>-sc-dimension
                                  attribute = <ld_s__i_cust_link>-sc-attribute ).

        ld_s__cust_link-object = <ld_s__i_cust_link>-sc-object.

      elseif <ld_s__i_cust_link>-sc-data is bound.
        ld_s__cust_link-data    = <ld_s__i_cust_link>-sc-data.
      elseif <ld_s__i_cust_link>-sc-const is not initial.
        ld_s__cust_link-const   = <ld_s__i_cust_link>-sc-const.
      elseif <ld_s__i_cust_link>-sc-clear = abap_true.
        ld_s__cust_link-clear = abap_true.
      endif.
      insert ld_s__cust_link into table ld_t__cust_link.
      check sy-subrc <> 0.
      modify table ld_t__cust_link from ld_s__cust_link.
    endloop.
  endif.

*╔═══════════════════════════════════════════════════════════════════╗
*║ Обрабока суперконстант                                            ║
*╠═══════════════════════════════════════════════════════════════════╣
  if gd_t__const is not initial and i_mode_add ne zbd0c_mode_add_line-change.
    loop at gd_t__const
      assigning <ld_s__const>.
      clear ld_s__cust_link.
      ld_s__cust_link-tg =  <ld_s__const>-tg.
      ld_s__cust_link-const   = <ld_s__const>-const.
      insert ld_s__cust_link into table ld_t__cust_link.
      check sy-subrc <> 0.
      modify table ld_t__cust_link from ld_s__cust_link.
    endloop.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝

*╔═══════════════════════════════════════════════════════════════════╗
*║ Вставка строки                                                    ║
*╠═══════════════════════════════════════════════════════════════════╣
  if i_mode_add is not initial.
    case i_mode_add.
      when zbd0c_mode_add_line-collect.
        if me->gr_o__model->gd_f__complete_key = abap_true.
          ld_s__rule_reestr-mode_add = zbd0c_mode_add_line-collect.
        else.
          "error
        endif.
      when zbd0c_mode_add_line-insert.
        ld_s__rule_reestr-mode_add = zbd0c_mode_add_line-insert.
      when zbd0c_mode_add_line-append.
        if me->gr_o__model->gd_s__handle-tab-tech_name->type_kind =
           cl_abap_tabledescr=>tablekind_std.
          ld_s__rule_reestr-mode_add = zbd0c_mode_add_line-append.
        else.
          "error
        endif.
      when zbd0c_mode_add_line-change.
        ld_s__rule_reestr-mode_add = zbd0c_mode_add_line-change.
    endcase.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝

*╔═══════════════════════════════════════════════════════════════════╗
*║ Обработчик правил для показателей                                 ║
*╠═══════════════════════════════════════════════════════════════════╣
  if is_math is not initial.
    loop at is_math-operand
         assigning <ld_s__rule_operand>.

      read table ld_t__cust_link "#EC *
           with key tg = gr_o__model->gd_v__signeddata
           assigning <ld_s__cust_link>.

      if sy-subrc <> 0.
        clear ld_s__cust_link.
        ld_s__cust_link-tg = gr_o__model->gd_v__signeddata.
        insert ld_s__cust_link into table ld_t__cust_link assigning <ld_s__cust_link>.
      endif.

      clear
      : <ld_s__cust_link>-object
      , <ld_s__cust_link>-data
      , <ld_s__cust_link>-sc
      , <ld_s__cust_link>-const
      .

      clear ld_s__cust_link.
      ld_s__cust_link-op = <ld_s__rule_operand>-var.

      if <ld_s__rule_operand>-object is bound.
        move <ld_s__rule_operand>-object to ld_s__cust_link-object.
        if <ld_s__rule_operand>-kyf is not initial.
          lr_o__appl_ctrl_kyf ?= <ld_s__rule_operand>-object.
          ld_s__cust_link-kyf = lr_o__appl_ctrl_kyf->gr_o__model->get_tech_alias( dimension = <ld_s__rule_operand>-kyf-dimension attribute = <ld_s__rule_operand>-kyf-attribute ).
        endif.
      elseif <ld_s__rule_operand>-data is bound.
        move <ld_s__rule_operand>-data to ld_s__cust_link-data.
      elseif <ld_s__rule_operand>-const is not initial.
        ld_s__cust_link-const = <ld_s__rule_operand>-const.
      endif.

*      ld_s__rule_math-object ?= <ld_s__rule_operand>-object.
      insert ld_s__cust_link into table ld_t__cust_link.
    endloop.

    if sy-subrc ne 0.
      clear ld_s__cust_link.
      ld_s__cust_link-tg = gr_o__model->gd_v__signeddata.
      insert ld_s__cust_link into table ld_t__cust_link assigning <ld_s__cust_link>.
    endif.

    read table ld_t__cust_link "#EC *
         with key tg = gr_o__model->gd_v__signeddata
         assigning <ld_s__cust_link>.

    <ld_s__cust_link>-const = is_math-exp.
  endif.

  ld_s__rule_reestr-rule_link = ld_t__cust_link.
  insert ld_s__rule_reestr into table gd_t__reestr_link.
*╚═══════════════════════════════════════════════════════════════════╝

  ld_s__class_reg-id        = e_id.
  ld_s__class_reg-main     = me.
  ld_s__class_reg-class     = zcl_bd00_int_table=>create_rule( e_id ).
  insert ld_s__class_reg into table gd_t__class_reg.

endmethod.

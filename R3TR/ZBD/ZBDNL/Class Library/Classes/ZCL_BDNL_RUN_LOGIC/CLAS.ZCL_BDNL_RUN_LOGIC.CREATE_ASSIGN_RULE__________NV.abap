method create_assign_rule__________nv.

  data
  : ld_t__rules_field         type zbd0t_ty_t_rule_field
  , ld_s__rules_field         type zbd0t_ty_s_rule_field
  , ld_s__assign              type zbnlt_s__assign
*  , ld_s__reestr_link         type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , ld_t__function            type zbnlt_t__function
  , ld_s__function            type zbnlt_s__function
  , ld_s__math                type zbd0t_ty_s_rule_math
  , ld_s__operand             type zbd0t_ty_s_math_operand
*  , lr_s__tg_containers       type ref to zbnlt_s__containers
*  , lr_s__sc_containers       type ref to zbnlt_s__containers
*  , lr_s__containers          type ref to zbnlt_s__containers
  , ld_v__mode_add            type zbd00_mode_add_line
  , ld_s__f_get_ch            type zbnlt_s__function
  , ld_s__check_exp           type zbnlt_s__check_exp
  , ld_t__check_exp           type zbnlt_t__check_exp
  , ld_s__check               type zbnlt_s__check
  , ld_v__turn                type i
  , ld_s__log_exp             type zbnlt_s__log_exp
  , ld_t__log_exp             type zbnlt_t__log_exp
  , ld_v__dtelnm              type rollname
  , ld_v__number_rules        type i
  , ld_v__message_char        type string
  , ld_v__message_kf          type string
  , ld_v__cnt                 type i
  , ld_s__link                type zbnlt_s__cust_link
  , lr_o__container           type ref to zcl_bdnl_container
  , lr_o__target              type ref to zcl_bdnl_container
  , lr_o__source              type ref to zcl_bdnl_container
  .

  field-symbols
  : <ld_s__assign>            type zbnlt_s__stack_assign
  , <ld_s__rules>             type zbnlt_s__for_rules
  , <ld_s__link>              type zbnlt_s__cust_link
  , <ld_t__check>             type zbnlt_t__stack_check
  , <ld_s__check>             type zbnlt_s__stack_check
  , <ld_s__mathvar>           type zbnlt_s__math_var
*  , <ld_s__tg_containers>     type zbnlt_s__containers
*  , <ld_s__sc_containers>     type zbnlt_s__containers
*  , <ld_s__containers>        type zbnlt_s__containers
  , <ld_v__data>              type uj_value
  .

  read table i_s__for-rules
       index i_v__turn
       assigning <ld_s__rules>.

  check sy-subrc = 0.
*  break-point.
  loop at <ld_s__rules>-assign assigning <ld_s__assign>.
    " обработка чеков
*    break-point.
    clear: ld_s__assign, ld_t__rules_field, ld_v__turn.

    do.
      add 1 to ld_v__turn.

      loop at <ld_s__assign>-check assigning <ld_s__check> where turn = ld_v__turn.

        clear: ld_s__log_exp, ld_s__check_exp.


        if <ld_s__check>-log_exp is not initial.

          ld_s__log_exp-log_exp = <ld_s__check>-log_exp.

          if  <ld_s__check>-left-tablename is not initial.

            lr_o__container ?= zcl_bdnl_container=>create_container( <ld_s__check>-left-tablename ).

            ld_v__dtelnm = lr_o__container->gr_o__container->gr_o__model->get_dtelnm( dimension = <ld_s__check>-left-dimension attribute = <ld_s__check>-left-attribute ).

            create data ld_s__log_exp-left type (ld_v__dtelnm).

            call method me->get_ch
              exporting
                i_o__obj      = lr_o__container->gr_o__container
                i_v__dim      = <ld_s__check>-left-dimension
                i_v__attr     = <ld_s__check>-left-attribute
                i_r__data     = ld_s__log_exp-left
              importing
                e_s__function = ld_s__f_get_ch.

            append ld_s__f_get_ch to ld_s__assign-function.

          elseif <ld_s__check>-left-const is not initial.
            create data ld_s__log_exp-left type uj_value.
            assign ld_s__log_exp-left->* to <ld_v__data>.
            <ld_v__data> = <ld_s__check>-left-const.
          elseif <ld_s__check>-left-data is bound.
            ld_s__link-data = <ld_s__check>-left-data.
            ld_s__link-func_name = <ld_s__check>-left-func_name.
            ld_s__link-param = <ld_s__check>-left-param.

            call method assign_function
              exporting
                i_s__function = ld_s__link
                i_v__turn     = i_s__for-turn
                i_s__for      = i_s__for
              importing
                e_t__function = ld_t__function.

            ld_s__log_exp-left = ld_s__link-data.

            append lines of ld_t__function to ld_s__assign-function.
            clear ld_t__function.

          endif.

          if  <ld_s__check>-right-tablename is not initial.

            lr_o__container ?= zcl_bdnl_container=>create_container( <ld_s__check>-right-tablename ).

            ld_v__dtelnm = lr_o__container->gr_o__container->gr_o__model->get_dtelnm( dimension = <ld_s__check>-right-dimension attribute = <ld_s__check>-right-attribute ).


            create data ld_s__log_exp-right type (ld_v__dtelnm).

            call method me->get_ch
              exporting
                i_o__obj      = lr_o__container->gr_o__container
                i_v__dim      = <ld_s__check>-right-dimension
                i_v__attr     = <ld_s__check>-right-attribute
                i_r__data     = ld_s__log_exp-right
              importing
                e_s__function = ld_s__f_get_ch.

            append ld_s__f_get_ch to ld_s__assign-function.

          elseif <ld_s__check>-right-const is not initial.
            create data ld_s__log_exp-right type uj_value.
            assign ld_s__log_exp-right->* to <ld_v__data>.
            <ld_v__data> = <ld_s__check>-right-const.
          elseif <ld_s__check>-right-data is bound.
            ld_s__link-data = <ld_s__check>-right-data.
            ld_s__link-func_name = <ld_s__check>-right-func_name.
            ld_s__link-param = <ld_s__check>-right-param.

            call method assign_function
              exporting
                i_s__function = ld_s__link
                i_v__turn     = i_s__for-turn
                i_s__for      = i_s__for
              importing
                e_t__function = ld_t__function.

            ld_s__log_exp-right = ld_s__link-data.

            append lines of ld_t__function to ld_s__assign-function.
            clear ld_t__function.
          endif.

          create data ld_s__log_exp-result type c length 1.
          ld_s__check_exp-data = ld_s__log_exp-result.

          append ld_s__check_exp  to ld_t__check_exp .
          append ld_s__log_exp    to ld_t__log_exp.

        elseif <ld_s__check>-token is not initial.
          ld_s__check_exp-operator = <ld_s__check>-token.
          append ld_s__check_exp  to ld_t__check_exp .
        endif.

*          lr_s__containers = create_container( i_v__tablename = <ld_s__check>-tablename i_s__for = i_s__for ).
*          assign lr_s__containers->* to <ld_s__containers>.
*
*          create data ld_s__check-data type uj_value.
*
*          call method me->get_ch
*            exporting
*              i_o__obj      = <ld_s__containers>-object
*              i_v__dim      = <ld_s__check>-dimension
*              i_v__attr     = <ld_s__check>-attribute
*              i_r__data     = ld_s__check-data
*            importing
*              e_s__function = ld_s__f_get_ch.
*
*          append ld_s__f_get_ch to ld_s__assign-function.
*          append ld_s__check to ld_t__check ."ld_s__assign-check.
*        elseif <ld_s__check>-const is not initial.
*          create data ld_s__check-data type uj_value.
*          assign ld_s__check-data->* to <ld_v__data>.
*          <ld_v__data> = <ld_s__check>-const.
*          append ld_s__check to ld_t__check ."ld_s__assign-check.
*        elseif <ld_s__check>-token is not initial.
*          ld_s__check-operator = <ld_s__check>-token.
*          append ld_s__check to ld_t__check ."ld_s__assign-check.
*        endif.
*
*        clear: ld_s__f_get_ch, ld_s__check.
      endloop.

      if sy-subrc ne 0.
        exit.
      else.
        ld_s__check-log_exp = ld_t__log_exp.
        ld_s__check-exp     = ld_t__check_exp.
        append ld_s__check to ld_s__assign-check.
        clear
        : ld_s__check
        , ld_t__log_exp
        , ld_t__check_exp
        .
      endif.

    enddo.
*--------------------------------------------------------------------*

    lr_o__target ?= zcl_bdnl_container=>create_container( <ld_s__assign>-tablename ).

    add 1 to ld_v__number_rules.
    message s051(zbdnl) with ld_v__number_rules <ld_s__assign>-tablename lr_o__target->gd_v__type_table.

    loop at <ld_s__assign>-link assigning <ld_s__link>.

      clear: ld_s__rules_field.

      if <ld_s__link>-tablename is not initial.

        lr_o__source ?= zcl_bdnl_container=>create_container( <ld_s__link>-tablename ).

        ld_s__rules_field-tg           = <ld_s__link>-tg.
        ld_s__rules_field-sc-dimension = <ld_s__link>-sc-dimension.
        ld_s__rules_field-sc-attribute = <ld_s__link>-sc-attribute.
        ld_s__rules_field-sc-object    = lr_o__source->gr_o__container.

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

        append lines of ld_t__function to ld_s__assign-function.
        clear ld_t__function.

        insert ld_s__rules_field into table ld_t__rules_field.
      endif.
    endloop.

    clear: ld_s__math.

    ld_s__math-exp = <ld_s__assign>-exp.

    if ld_s__math-exp is not initial.
      ld_v__message_kf = `SIGNEDDATA`.
    else.
      ld_v__message_kf = space.
    endif.

    loop at <ld_s__assign>-variables assigning <ld_s__mathvar>.
      clear ld_s__operand.

      ld_s__operand-var   = <ld_s__mathvar>-varname.
      if <ld_s__mathvar>-tablename is not initial and <ld_s__mathvar>-dimension is initial.

        lr_o__source ?= zcl_bdnl_container=>create_container( <ld_s__mathvar>-tablename ).

        ld_s__operand-object = lr_o__source->gr_o__container.

      elseif <ld_s__mathvar>-tablename is not initial and <ld_s__mathvar>-dimension is not initial.

        lr_o__source ?= zcl_bdnl_container=>create_container( <ld_s__mathvar>-tablename ).

        ld_s__operand-object = lr_o__source->gr_o__container.
        ld_s__operand-kyf-dimension = <ld_s__mathvar>-dimension.
        ld_s__operand-kyf-attribute = <ld_s__mathvar>-attribute.

*        create data ld_s__operand-data type  uj_keyfigure.
*
*        call method me->get_ch
*          exporting
*            i_o__obj      = <ld_s__sc_containers>-object
*            i_v__dim      = <ld_s__mathvar>-dimension
*            i_v__attr     = <ld_s__mathvar>-attribute
*            i_r__data     = ld_s__operand-data
*          importing
*            e_s__function = ld_s__function.
*
*        append ld_s__function to ld_s__assign-function.
*        clear ld_t__function.

      elseif <ld_s__mathvar>-data is bound.
        ld_s__operand-data = <ld_s__mathvar>-data.
        ld_s__link-data = ld_s__operand-data.
        ld_s__link-func_name = <ld_s__mathvar>-func_name.
        ld_s__link-param = <ld_s__mathvar>-param.

        call method assign_function
          exporting
            i_s__function = ld_s__link
            i_v__turn     = i_s__for-turn
            i_s__for      = i_s__for
          importing
            e_t__function = ld_t__function.

        append lines of ld_t__function to ld_s__assign-function.
        clear ld_t__function.

      endif.

      insert ld_s__operand into table ld_s__math-operand.

    endloop.

    ld_s__assign-tablename = <ld_s__assign>-tablename.
    ld_s__assign-command   = lr_o__target->gd_v__command.

    if i_s__for-tablename = ld_s__assign-tablename.
      ld_v__mode_add  = zbd0c_mode_add_line-change.
    else.
      ld_v__mode_add  = zbd0c_mode_add_line-collect.
    endif.

    ld_s__assign-id = lr_o__target->gr_o__container->set_rule_assign( it_field   = ld_t__rules_field
                                                                      i_mode_add = ld_v__mode_add "zbd0c_mode_add_line-collect
                                                                      is_math    = ld_s__math ).

    ld_s__assign-class = zcl_bd00_appl_ctrl=>get_rule_class( ld_s__assign-id ).

*--------------------------------------------------------------------*
* Message
*--------------------------------------------------------------------*
    clear
    : ld_v__cnt
    , ld_v__message_char
    .
    loop at ld_t__rules_field into ld_s__rules_field.
      add 1 to ld_v__cnt.

      if ld_v__cnt = 1.
        if ld_s__rules_field-tg-attribute is initial.
          ld_v__message_char = ld_s__rules_field-tg-dimension.
        else.
          concatenate ld_s__rules_field-tg-dimension `~` ld_s__rules_field-tg-attribute into ld_v__message_char.
        endif.
      else.
        if ld_s__rules_field-tg-attribute is initial.
          concatenate ld_v__message_char ` ` ld_s__rules_field-tg-dimension into ld_v__message_char.
        else.
          concatenate ld_v__message_char ` ` ld_s__rules_field-tg-dimension `~` ld_s__rules_field-tg-attribute into ld_v__message_char.
        endif.
      endif.
    endloop.

    message s052(zbdnl) with ld_v__message_char ld_v__message_kf.
*--------------------------------------------------------------------*


    ld_s__assign-object = lr_o__target->gr_o__container.
    if <ld_s__assign>-f_found = abap_true.
      append ld_s__assign to e_t__assign.
    else.
      append ld_s__assign to e_t__assign_not_found.
    endif.

  endloop.

endmethod.

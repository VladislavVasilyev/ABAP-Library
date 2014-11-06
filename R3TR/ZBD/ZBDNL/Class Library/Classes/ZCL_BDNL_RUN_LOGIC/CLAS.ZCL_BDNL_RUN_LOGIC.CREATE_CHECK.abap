method create_check.

  data
  : ld_t__function            type zbnlt_t__function
  , ld_s__f_get_ch            type zbnlt_s__function
  , ld_s__check_exp           type zbnlt_s__check_exp
  , ld_t__check_exp           type zbnlt_t__check_exp
  , ld_s__check               type zbnlt_s__check
  , ld_v__turn                type i
  , ld_s__log_exp             type zbnlt_s__log_exp
  , ld_t__log_exp             type zbnlt_t__log_exp
  , ld_v__dtelnm              type rollname
  , ld_s__link                type zbnlt_s__cust_link
  , lr_o__container           type ref to zcl_bdnl_container
  , ld_s__param               type zbnlt_s__func_param
  .

  field-symbols
  : <ld_s__check>             type zbnlt_s__stack_check
  , <ld_v__data>              type uj_value
  .

  check i_t__check is not initial.

  refresh: e_t__check, e_t__function.

  do.
    add 1 to ld_v__turn.

    loop at i_t__check assigning <ld_s__check> where turn = ld_v__turn.

      clear: ld_s__log_exp, ld_s__check_exp.


      if <ld_s__check>-log_exp is not initial.

        ld_s__log_exp-log_exp = <ld_s__check>-log_exp.

        if  <ld_s__check>-left-tablename is not initial.

          lr_o__container = zcl_bdnl_container=>create_container( <ld_s__check>-left-tablename ).

          ld_v__dtelnm = lr_o__container->gr_o__container->gr_o__model->get_dtelnm( dimension = <ld_s__check>-left-dimension attribute = <ld_s__check>-left-attribute ).

          create data ld_s__log_exp-left type (ld_v__dtelnm).

          call method zcl_bdnl_parser_service=>get_ch
            exporting
              i_o__obj      = lr_o__container->gr_o__container
              i_v__dim      = <ld_s__check>-left-dimension
              i_v__attr     = <ld_s__check>-left-attribute
              i_r__data     = ld_s__log_exp-left
            importing
              e_s__function = ld_s__f_get_ch.

          append ld_s__f_get_ch to e_t__function.

        elseif <ld_s__check>-left-const is not initial.
          create data ld_s__log_exp-left type uj_value.
          assign ld_s__log_exp-left->* to <ld_v__data>.
          <ld_v__data> = <ld_s__check>-left-const.
        elseif <ld_s__check>-left-data is bound.
          ld_s__link-data = <ld_s__check>-left-data.
          ld_s__link-func_name = <ld_s__check>-left-func_name.
          ld_s__link-param = <ld_s__check>-left-param.

          call method zcl_bdnl_parser_service=>create_assign_function
            exporting
              i_s__function = ld_s__link
            importing
              e_t__function = ld_t__function.

          ld_s__log_exp-left = ld_s__link-data.

          append lines of ld_t__function to e_t__function.
          clear ld_t__function.

        endif.

        if  <ld_s__check>-right-tablename is not initial.

          lr_o__container = zcl_bdnl_container=>create_container( <ld_s__check>-right-tablename ).

          ld_v__dtelnm = lr_o__container->gr_o__container->gr_o__model->get_dtelnm( dimension = <ld_s__check>-right-dimension attribute = <ld_s__check>-right-attribute ).

          create data ld_s__log_exp-right type (ld_v__dtelnm).

          call method zcl_bdnl_parser_service=>get_ch
            exporting
              i_o__obj      = lr_o__container->gr_o__container
              i_v__dim      = <ld_s__check>-right-dimension
              i_v__attr     = <ld_s__check>-right-attribute
              i_r__data     = ld_s__log_exp-right
            importing
              e_s__function = ld_s__f_get_ch.

          append ld_s__f_get_ch to e_t__function.

        elseif <ld_s__check>-right-const is not initial.
          create data ld_s__log_exp-right type uj_value.
          assign ld_s__log_exp-right->* to <ld_v__data>.
          <ld_v__data> = <ld_s__check>-right-const.
        elseif <ld_s__check>-right-data is bound.
          ld_s__link-data = <ld_s__check>-right-data.
          ld_s__link-func_name = <ld_s__check>-right-func_name.
          ld_s__link-param = <ld_s__check>-right-param.

          call method zcl_bdnl_parser_service=>create_assign_function
            exporting
              i_s__function = ld_s__link
            importing
              e_t__function = ld_t__function.

          ld_s__log_exp-right = ld_s__link-data.

          append lines of ld_t__function to e_t__function.
          clear ld_t__function.
        endif.

        if <ld_s__check>-in = abap_true.
*--------------------------------------------------------------------*
* CONVERT to RANGE TABLE
*--------------------------------------------------------------------*
          ld_s__param-index = 1.
          ld_s__param-data = ld_s__log_exp-right.
          append ld_s__param to ld_s__link-param.


          case <ld_s__check>-log_exp.
            when zblnc_keyword-ne.
              ld_s__param-index = 2.
              ld_s__param-const = 'E'.
              append ld_s__param to ld_s__link-param.

              ld_s__param-index = 3.
              ld_s__param-const = 'EQ'.
              append ld_s__param to ld_s__link-param.
            when others.
              ld_s__param-index = 2.
              ld_s__param-const = 'I'.
              append ld_s__param to ld_s__link-param.

              ld_s__param-index = 3.
              ld_s__param-const = <ld_s__check>-log_exp.
              append ld_s__param to ld_s__link-param.
          endcase.


          ld_s__log_exp-log_exp = `IN`.
          ld_s__log_exp-right = create_range_ref( i_ref = ld_s__log_exp-left ).

          ld_s__link-data = ld_s__log_exp-right.
          ld_s__link-func_name = `__CONVERT_TO_RANGE_TABLE` .

          call method zcl_bdnl_parser_service=>create_assign_function
            exporting
              i_s__function = ld_s__link
            importing
              e_t__function = ld_t__function.

          append lines of ld_t__function to e_t__function.
          clear ld_t__function.
*--------------------------------------------------------------------*
          create data ld_s__log_exp-result type c length 1.
          ld_s__check_exp-data = ld_s__log_exp-result.

          append ld_s__check_exp  to ld_t__check_exp .
          append ld_s__log_exp    to ld_t__log_exp.
        else.
          create data ld_s__log_exp-result type c length 1.
          ld_s__check_exp-data = ld_s__log_exp-result.

          append ld_s__check_exp  to ld_t__check_exp .
          append ld_s__log_exp    to ld_t__log_exp.
        endif.
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
      append ld_s__check to e_t__check.
      clear
      : ld_s__check
      , ld_t__log_exp
      , ld_t__check_exp
      .
    endif.

  enddo.
*--------------------------------------------------------------------*

endmethod.

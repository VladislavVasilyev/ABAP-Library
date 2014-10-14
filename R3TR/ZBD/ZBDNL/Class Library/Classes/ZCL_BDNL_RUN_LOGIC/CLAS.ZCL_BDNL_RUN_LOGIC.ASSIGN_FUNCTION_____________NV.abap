method assign_function_____________nv.

  data
  : lr_o__classdescr    type ref to cl_abap_classdescr
  , ld_s__method        type abap_methdescr
  , lt_s__methparam     type abap_parmdescr
  , ld_t__funcparam     type standard table of string
  , ld_s__funcparam     type zbnlt_s__func_param
  , ld_s__bindparam     type abap_parmbind
  , ld_t__bindparam     type abap_parmbind_tab
  , ld_v__cntparam      type i value 0
  , ld_s__function      type zbnlt_s__function
  , ld_s__f_get_ch      type zbnlt_s__function
  , ld_s__bindforget    type abap_parmbind
  , lr_s__containers    type ref to zbnlt_s__containers
  , ld_v__dtelnm        type rollname
  , lr_o__container     type ref to zcl_bdnl_container
  .

  field-symbols
  : <data>              type any
  , <ld_s__bindparam>   type abap_parmbind
*  , <ld_s__containers>  type zbnlt_s__containers
  .

  lr_o__classdescr ?= cl_abap_classdescr=>describe_by_name( `ZCL_BDNL_ASSIGN_FUNCTION`  ).

  read table lr_o__classdescr->methods
       with key name = i_s__function-func_name
       into ld_s__method.

  sort ld_s__method-parameters by name ascending.

  loop at ld_s__method-parameters into lt_s__methparam.

    case lt_s__methparam-parm_kind.
      when cl_abap_classdescr=>importing.
        add 1 to ld_v__cntparam.
        read table i_s__function-param with key index = ld_v__cntparam into ld_s__funcparam.

        if sy-subrc ne 0." Включить проверку опциональности
          continue.
        endif.

        if ld_s__funcparam-const is not initial.
          create data ld_s__bindparam-value type uj_value.
          assign ld_s__bindparam-value->* to <data>.
          <data> = ld_s__funcparam-const.
        elseif ld_s__funcparam-tablename is not initial.

          lr_o__container ?= zcl_bdnl_container=>create_container( ld_s__funcparam-tablename ).

*          lr_s__containers = create_container( i_v__tablename = ld_s__funcparam-tablename i_s__for = i_s__for ).
*          assign lr_s__containers->* to <ld_s__containers>.
          ld_v__dtelnm = lr_o__container->gr_o__container->gr_o__model->get_dtelnm( dimension = ld_s__funcparam-field-dimension attribute = ld_s__funcparam-field-attribute ).

          create data ld_s__bindparam-value type (ld_v__dtelnm).

          call method me->get_ch
            exporting
              i_o__obj      = lr_o__container->gr_o__container
              i_v__dim      = ld_s__funcparam-field-dimension
              i_v__attr     = ld_s__funcparam-field-attribute
              i_r__data     = ld_s__bindparam-value
            importing
              e_s__function = ld_s__f_get_ch.

          append ld_s__f_get_ch to e_t__function.

        endif.

        ld_s__bindparam-kind = cl_abap_classdescr=>exporting.
      when cl_abap_classdescr=>exporting.
        ld_s__bindparam-kind = cl_abap_classdescr=>importing.
        ld_s__bindparam-value = i_s__function-data.
    endcase.

    ld_s__bindparam-name = lt_s__methparam-name.
    ld_s__function-func_name = i_s__function-func_name.
    insert ld_s__bindparam into table ld_s__function-bindparam.
  endloop.

  append ld_s__function to e_t__function.
endmethod.

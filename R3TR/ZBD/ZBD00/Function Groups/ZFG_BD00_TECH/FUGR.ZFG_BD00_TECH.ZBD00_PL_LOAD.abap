function zbd00_pl_load.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_V__APPSET_ID) TYPE  UJ_APPSET_ID
*"     VALUE(I_V__SC_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_V__TG_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_V__SCENARIO) TYPE  UJ_VALUE
*"     VALUE(I_V__FORMAT) TYPE  UJ_VALUE OPTIONAL
*"     VALUE(I_T__BPCTIME) TYPE  ZBD00_T_BPCTIME
*"     VALUE(I_V__PACKAGESIZE) TYPE  I OPTIONAL
*"     VALUE(I_V__ID_RULE) TYPE  I
*"     VALUE(I_BPC_USER) TYPE  UJ0_S_USER OPTIONAL
*"  EXPORTING
*"     VALUE(NUM_READ) TYPE  I
*"     VALUE(NUM_WRITE) TYPE  UJR_S_STATUS_RECORDS
*"     VALUE(E_MESSAGE) TYPE  UJ0_T_MESSAGE
*"  TABLES
*"      I_T__ENTITY_RANGE TYPE  UJ0_T_SEL OPTIONAL
*"  CHANGING
*"     VALUE(TASK_ID) TYPE  I OPTIONAL
*"  EXCEPTIONS
*"      ERR_TARGET_CREATE
*"      ERR_APPSET_ID
*"      ERR_SOURCE_CREATE
*"----------------------------------------------------------------------
  define mac__add_to_range.
    clear ld_s__range.
    ld_s__range-dimension = &1.
    ld_s__range-attribute = &2.
    ld_s__range-sign      = `I`.
    ld_s__range-option    = &3.
    ld_s__range-low       = &4.
    if &3 = 'NE'.
      ld_s__range-sign      = `E` .
      ld_s__range-option    = 'EQ' .
    endif.
    append ld_s__range to ld_t__range.
  end-of-definition.
  define mac__add_to_clear_range.
    clear ld_s__range.
    ld_s__range-dimension = &1.
    ld_s__range-attribute = &2.
    ld_s__range-sign      = `I`.
    ld_s__range-option    = &3.
    ld_s__range-low       = &4.
    if &3 = 'NE'.
      ld_s__range-sign      = `E` .
      ld_s__range-option    = 'EQ' .
    endif.
    append ld_s__range to ld_t__clear_range.
  end-of-definition.
  define mac__add_to_const.
    clear ld_s__const.
    ld_s__const-dimension = &1.
    ld_s__const-const     = &2.
    insert ld_s__const into table ld_t__const.
  end-of-definition.
  define mac__add_to_link.
    clear ld_s__link.
    ld_s__link-tg-dimension = &1.
    ld_s__link-sc-dimension = &2.
    ld_s__link-sc-attribute = &3.
    insert ld_s__link into table  ld_t__link.
  end-of-definition.
  define mac__add_to_dimlist.
    clear ld_s__dim_list.
    add 1 to ld_v__cnt.
    ld_s__dim_list-dimension = &1.
    ld_s__dim_list-attribute = &2.
    ld_s__dim_list-orderby = ld_v__cnt.
    insert ld_s__dim_list into table ld_t__dim_list.
  end-of-definition.
*--------------------------------------------------------------------*
*  zcl_debug=>stop_program( ) .
*--------------------------------------------------------------------*
  if `DATA`       = `DATA`      .
    type-pools zbnlt.

    types
    : begin of ty_mp_pl
    , tg_dimn	    type uj_dim_name
    , tg_value    type uj_value
    , sc_dimn	    type uj_dim_name
    , sc_value    type uj_value
    , end of ty_mp_pl
    , begin of ty_mp_pl_rl
    , id    type uj_id
    , attr  type uj_attr_name
    , opti  type c length 2
    , value	type uj_value
    , end of ty_mp_pl_rl.

    data
    : lr_o__source          type ref to zcl_bd00_appl_table
    , lr_o__target          type ref to zcl_bd00_appl_table
    , lr_o__rfc_task        type ref to zcl_bd00_rfc_task
    , lr_o__security        type ref to cl_uje_check_security
    , lr_o__model           type ref to zcl_bd00_model

    , ld_v__bpctime         type zbd00_bpctime
    , ld_v__dimension       type uj_dim_name
    , ld_v__attribute       type uj_attr_name
    , ld_v__value           type uj_value
    , ld_v__rule_assign     type zbd0t_id_rules
    , ld_v__koef            type string
    , ld_v__cnt             type i
    , ld_v__string          type string
    , ld_v__member          type string

    , ld_s__const           type zbd0t_ty_s_constant
    , ld_s__mp_pl           type ty_mp_pl
    , ld_s__mp_pl_rl        type ty_mp_pl_rl
    , ld_s__link            type zbd0t_ty_s_link_key
    , ld_s__dim_list        type zbd00_s_ch_key
    , ld_s__range           type uj0_s_sel
    , ld_s__user            type uj0_s_user
    , ld_s__rules_math      type zbd0t_ty_s_rule_math
    , ld_s__operand         type zbd0t_ty_s_math_operand

    , ld_t__const           type zbd0t_ty_t_constant
    , ld_t__mp_pl           type sorted table of ty_mp_pl with non-unique key tg_dimn
    , ld_t__mp_pl_rl        type sorted table of ty_mp_pl_rl with non-unique key id
    , ld_t__link            type zbd0t_ty_t_link_key
    , ld_t__dim_list        type zbd00_t_ch_key
    , ld_t__clear_range     type uj0_t_sel
    , ld_t__range           type uj0_t_sel
    , ld_t__param           type zbnlt_t__param
    , ld_t__log_read        type zbd0t_t__log_read
    , ld_t__log_read_dim    type zbd0t_t__log_dimension
    , ld_t__log_write       type zbd0t_t__log_write
    .

    field-symbols
    : <ld_t__dim_list>      type zcl_bd00_model=>ty_t_dim_list
    , <ld_s__dim_list>      type zcl_bd00_model=>ty_s_dim_list
    , <ld_t__mp_pl>         type ty_mp_pl
    .
  endif.
  if `CONTEXT`    = `CONTEXT`   .

    call method zcl_bd00_context=>set_context
      exporting
        i_appset_id = i_v__appset_id
        i_appl_id   = i_v__tg_appl_id
        i_s__user   = i_bpc_user.

*    create object lr_o__security.
*    ld_s__user-user_id = lr_o__security->d_server_admin_id.
* ---> Добавил Козин А., X5, 30.09.2014
    try.
        cl_uj_context=>set_cur_context( i_appset_id = i_v__appset_id is_user = i_bpc_user ).
      catch cx_uj_obj_not_found.
        raise err_appset_id.
    endtry.
* <---

    create object lr_o__rfc_task
      exporting
        num           = 4
        parallel_task = abap_true.
  endif.
  if `TARGET`     = `TARGET`    .
    select  tg_dimn tg_value sc_dimn sc_value
      from  zrb_mp_pl
      into corresponding fields of table ld_t__mp_pl
           where id_rule = i_v__id_rule
             and appset  = i_v__appset_id
             and tg_appl = i_v__tg_appl_id
             and tg_dimn <> space
             and sc_appl = i_v__sc_appl_id
          order by tg_dimn ascending.

    try.
        lr_o__model ?= zcl_bd00_model=>get_model( i_appset_id = i_v__appset_id
                                                  i_appl_id   = i_v__tg_appl_id
                                                  i_type_pk   = zbd0c_ty_tab-has_unique_dk ).
      catch zcx_bd00_create_obj.
        raise err_target_create.
    endtry.

    assign lr_o__model->gr_t__dimension->* to  <ld_t__dim_list>.

    loop at <ld_t__dim_list> assigning <ld_s__dim_list>.

      read table ld_t__mp_pl
           with table key tg_dimn = <ld_s__dim_list>-dimension
           assigning <ld_t__mp_pl>.

      if sy-subrc = 0.
        if <ld_t__mp_pl>-tg_value is not initial.

          case <ld_s__dim_list>-type.
            when zcl_bd00_application=>cs_dm.

              mac__add_to_const
              : <ld_t__mp_pl>-tg_dimn <ld_t__mp_pl>-tg_value.

              mac__add_to_clear_range
              : <ld_t__mp_pl>-tg_dimn `` `EQ`  <ld_t__mp_pl>-tg_value.

            when zcl_bd00_application=>cs_kf.
              ld_v__koef = <ld_t__mp_pl>-tg_value.
          endcase.

        else.
          split <ld_t__mp_pl>-sc_dimn at `.` into ld_v__dimension ld_v__attribute.

          mac__add_to_link
          : <ld_s__dim_list>-dimension ld_v__dimension ld_v__attribute.

          mac__add_to_dimlist
          : ld_v__dimension ld_v__attribute.

        endif.
      else.
        mac__add_to_link
        : <ld_s__dim_list>-dimension <ld_s__dim_list>-dimension ``.

        mac__add_to_dimlist
        : <ld_s__dim_list>-dimension ``.

      endif.
    endloop.

    mac__add_to_range
    : `SCENARIO` ``           `EQ` i_v__scenario.

    if i_v__format is supplied.
      mac__add_to_range
      : `ENTITY`   `FORMAT_N`   `EQ` i_v__format.
    endif.

    if lines( i_t__entity_range ) > 0 .
      clear ld_s__range.
      loop at i_t__entity_range into ld_s__range .
        collect ld_s__range into ld_t__range .
      endloop.
    endif.

    loop at i_t__bpctime into ld_v__bpctime.
      mac__add_to_range
      : `TIME` `` `EQ`  ld_v__bpctime.
    endloop.
  endif.
  if `SOURCE`     = `SOURCE`    .
    select  tg_dimn tg_value sc_dimn sc_value
      from  zrb_mp_pl
      into corresponding fields of ld_s__mp_pl
           where id_rule = i_v__id_rule
             and appset  = i_v__appset_id
             and tg_appl = i_v__tg_appl_id
             and sc_dimn <> space
             and sc_appl = i_v__sc_appl_id
           order by sc_dimn ascending.

      find regex `^<([A-Z0-9\_]+)>` in ld_s__mp_pl-sc_value.

      if sy-subrc = 0.
        ld_v__string = ld_s__mp_pl-sc_value.
        replace all occurrences of regex `(<|>)` in ld_v__string with space.

        select id attr opti value
          from  zrb_mp_pl_rl
          into corresponding fields of ld_s__mp_pl_rl
               where  appset  = i_v__appset_id
               and    id      = ld_v__string.

          ld_v__dimension = ld_s__mp_pl-sc_dimn.
          if ld_s__mp_pl_rl-attr = `ID`.
            clear ld_v__attribute.
          else.
            ld_v__attribute = ld_s__mp_pl_rl-attr.
          endif.

          find regex `^BAS\([A-Z0-9\_]+\)` in ld_s__mp_pl_rl-value.

          if sy-subrc = 0.
            replace all occurrences of regex `(^BAS\(|\))` in  ld_s__mp_pl_rl-value with space.
            ld_v__member = cl_ujk_util=>bas( i_dim_name = ld_v__dimension i_member = ld_s__mp_pl_rl-value ).
            split ld_v__member at ',' into table ld_t__param.
            loop at ld_t__param into ld_v__value.

              mac__add_to_range
              : ld_v__dimension ld_v__attribute ld_s__mp_pl_rl-opti ld_v__value.

              if ld_s__mp_pl-tg_dimn is not initial and ld_s__mp_pl-tg_value is initial.
                ld_v__dimension = ld_s__mp_pl-tg_dimn.

                mac__add_to_clear_range
                : ld_v__dimension `` ld_s__mp_pl_rl-opti ld_s__mp_pl_rl-value.

              endif.
            endloop.
          else.
            mac__add_to_range
            : ld_v__dimension ld_v__attribute ld_s__mp_pl_rl-opti ld_s__mp_pl_rl-value.

            mac__add_to_clear_range
            : ld_v__dimension ld_v__attribute ld_s__mp_pl_rl-opti ld_s__mp_pl_rl-value.

          endif.
        endselect.
      elseif ld_s__mp_pl-sc_value is not initial.
        split ld_s__mp_pl-sc_dimn at `.` into ld_v__dimension ld_v__attribute.

        mac__add_to_range
        : ld_v__dimension ld_v__attribute  `EQ` ld_s__mp_pl-sc_value.

      endif.
    endselect.
    mac__add_to_clear_range
    : `SCENARIO` ``           `EQ` i_v__scenario.

    if i_v__format is supplied.
      mac__add_to_range
      : `ENTITY`   `FORMAT_N`   `EQ` i_v__format.
    endif.

    if lines( i_t__entity_range ) > 0 .
      clear ld_s__range.
      loop at i_t__entity_range into ld_s__range .
        collect ld_s__range into ld_t__clear_range .
      endloop.
    endif.

    loop at i_t__bpctime into ld_v__bpctime.
      mac__add_to_clear_range `TIME` `` `EQ`  ld_v__bpctime.
    endloop.

  endif.
  if `CLEAR`      = `NOCLEAR`   .
    try.
        create object lr_o__target
          exporting
            i_appset_id = i_v__appset_id
            i_appl_id   = i_v__tg_appl_id
            it_range    = ld_t__clear_range
            i_type_pk   = zbd0c_ty_tab-std_non_unique_dk
            if_invert   = abap_true.
      catch zcx_bd00_create_obj.
        raise err_target_create.
    endtry.

    while lr_o__target->next_pack( zbd0c_read_mode-pack ) eq zbd0c_read_pack .
      lr_o__target->write_back( abap_true ).
    endwhile.
    zcl_bd00_appl_table=>free_all_object( ).
  endif.
  if `CONTAINERS` = `CONTAINERS`.
    try.
        create object lr_o__target
          exporting
            i_appset_id  = i_v__appset_id
            i_appl_id    = i_v__tg_appl_id
            i_type_pk    = zbd0c_ty_tab-has_unique_dk
            if_auto_save = abap_true
            it_const     = ld_t__const.
      catch zcx_bd00_create_obj.
        raise err_target_create.
    endtry.

    try.
        create object lr_o__source
          exporting
            i_appset_id   = i_v__appset_id
            i_appl_id     = i_v__sc_appl_id
            it_range      = ld_t__range
            it_dim_list   = ld_t__dim_list
            i_packagesize = i_v__packagesize
            i_type_pk     = zbd0c_ty_tab-std_non_unique_dk.
      catch zcx_bd00_create_obj.
        raise err_source_create.
    endtry.
  endif.
  if `RULES`      = `RULES`     .
    concatenate `SOURCE * ` ld_v__koef into  ld_s__rules_math-exp.

    ld_s__operand-var    = `SOURCE`.
    ld_s__operand-object = lr_o__source.
    insert ld_s__operand into table ld_s__rules_math-operand.

    ld_v__rule_assign =
    lr_o__target->set_rule_assign( is_math    = ld_s__rules_math
                                   io_default = lr_o__source
                                   it_link    = ld_t__link
                                   i_mode_add = zbd0c_mode_add_line-collect ).
  endif.
  if `WORK_CYCLE` = `WORK_CYCLE`.
    while lr_o__source->next_pack( zbd0c_read_mode-pack ) eq zbd0c_read_pack.
      while lr_o__source->next_line( ) eq zbd0c_found.
        lr_o__target->rule_assign( ld_v__rule_assign ).
      endwhile.
    endwhile.
    lr_o__target->write_back( ).
  endif.

  zcl_bd00_rfc_task=>wait_end_all_task( ).

  call method lr_o__source->get_log
    importing
      e_t__read = ld_t__log_read.

  call method lr_o__target->get_log
    importing
      e_t__write = ld_t__log_write.



  field-symbols
  : <ld_s__log_read>  like line of ld_t__log_read
  , <ld_s__log_write> like line of ld_t__log_write
  .

  loop at ld_t__log_read assigning <ld_s__log_read>.
    add <ld_s__log_read>-sup_rec to num_read.
  endloop.

  loop at ld_t__log_write assigning <ld_s__log_write>.
    add <ld_s__log_write>-status_records-nr_submit to num_write-nr_submit.
    add <ld_s__log_write>-status_records-nr_fail to num_write-nr_fail.
    add <ld_s__log_write>-status_records-nr_success to num_write-nr_success.

    append lines of <ld_s__log_write>-message to e_message.
  endloop.

  sort e_message.
  delete adjacent duplicates from e_message.

  zcl_bd00_appl_table=>free_all_object( ).

*    e_t__read     = ld_t__log_read
*    e_t__read_dim = ld_t__log_read_dim
*--------------------------------------------------------------------*
endfunction.

FUNCTION zbd00_pl_load.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_V__APPSET_ID) TYPE  UJ_APPSET_ID
*"     VALUE(I_V__SC_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_V__TG_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_V__SCENARIO) TYPE  UJ_VALUE
*"     VALUE(I_V__FORMAT) TYPE  UJ_VALUE
*"     VALUE(I_T__BPCTIME) TYPE  ZBD00_T_BPCTIME
*"     VALUE(I_V__PACKAGESIZE) TYPE  I OPTIONAL
*"     VALUE(I_V__ID_RULE) TYPE  I
*"  EXPORTING
*"     VALUE(NUM_READ) TYPE  I
*"     VALUE(NUM_WRITE) TYPE  UJR_S_STATUS_RECORDS
*"     VALUE(E_MESSAGE) TYPE  UJ0_T_MESSAGE
*"  EXCEPTIONS
*"      ERR_TARGET_CREATE
*"      ERR_APPSET_ID
*"      ERR_SOURCE_CREATE
*"----------------------------------------------------------------------
  DEFINE mac__add_to_range.
    clear ld_s__range.
    ld_s__range-dimension = &1.
    ld_s__range-attribute = &2.
    ld_s__range-sign      = `I`.
    ld_s__range-option    = &3.
    ld_s__range-low       = &4.
    append ld_s__range to ld_t__range.
  END-OF-DEFINITION.
  DEFINE mac__add_to_clear_range.
    clear ld_s__range.
    ld_s__range-dimension = &1.
    ld_s__range-attribute = &2.
    ld_s__range-sign      = `I`.
    ld_s__range-option    = &3.
    ld_s__range-low       = &4.
    append ld_s__range to ld_t__clear_range.
  END-OF-DEFINITION.
  DEFINE mac__add_to_const.
    clear ld_s__const.
    ld_s__const-dimension = &1.
    ld_s__const-const     = &2.
    insert ld_s__const into table ld_t__const.
  END-OF-DEFINITION.
  DEFINE mac__add_to_link.
    clear ld_s__link.
    ld_s__link-tg-dimension = &1.
    ld_s__link-sc-dimension = &2.
    ld_s__link-sc-attribute = &3.
    insert ld_s__link into table  ld_t__link.
  END-OF-DEFINITION.
  DEFINE mac__add_to_dimlist.
    clear ld_s__dim_list.
    add 1 to ld_v__cnt.
    ld_s__dim_list-dimension = &1.
    ld_s__dim_list-attribute = &2.
    ld_s__dim_list-orderby = ld_v__cnt.
    insert ld_s__dim_list into table ld_t__dim_list.
  END-OF-DEFINITION.
*--------------------------------------------------------------------*

*ZCL_DEBUG=>stop_program( ) .
*--------------------------------------------------------------------*
  IF `DATA`       = `DATA`      .
    TYPE-POOLS zbnlt.

    TYPES
    : BEGIN OF ty_mp_pl
    , tg_dimn	    TYPE uj_dim_name
    , tg_value    TYPE uj_value
    , sc_dimn	    TYPE uj_dim_name
    , sc_value    TYPE uj_value
    , END OF ty_mp_pl
    , BEGIN OF ty_mp_pl_rl
    , id    TYPE uj_id
    , attr  TYPE uj_attr_name
    , opti  TYPE c LENGTH 2
    , value	TYPE uj_value
    , END OF ty_mp_pl_rl.

    DATA
    : lr_o__source          TYPE REF TO zcl_bd00_appl_table
    , lr_o__target          TYPE REF TO zcl_bd00_appl_table
    , lr_o__rfc_task        TYPE REF TO zcl_bd00_rfc_task
    , lr_o__security        TYPE REF TO cl_uje_check_security
    , lr_o__model           TYPE REF TO zcl_bd00_model

    , ld_v__bpctime         TYPE zbd00_bpctime
    , ld_v__dimension       TYPE uj_dim_name
    , ld_v__attribute       TYPE uj_attr_name
    , ld_v__value           TYPE uj_value
    , ld_v__rule_assign     TYPE zbd0t_id_rules
    , ld_v__koef            TYPE string
    , ld_v__cnt             TYPE i
    , ld_v__string          TYPE string
    , ld_v__member          TYPE string

    , ld_s__const           TYPE zbd0t_ty_s_constant
    , ld_s__mp_pl           TYPE ty_mp_pl
    , ld_s__mp_pl_rl        TYPE ty_mp_pl_rl
    , ld_s__link            TYPE zbd0t_ty_s_link_key
    , ld_s__dim_list        TYPE zbd00_s_ch_key
    , ld_s__range           TYPE uj0_s_sel
    , ld_s__user            TYPE uj0_s_user
    , ld_s__rules_math      TYPE zbd0t_ty_s_rule_math
    , ld_s__operand         TYPE zbd0t_ty_s_math_operand

    , ld_t__const           TYPE zbd0t_ty_t_constant
    , ld_t__mp_pl           TYPE SORTED TABLE OF ty_mp_pl WITH NON-UNIQUE KEY tg_dimn
    , ld_t__mp_pl_rl        TYPE SORTED TABLE OF ty_mp_pl_rl WITH NON-UNIQUE KEY id
    , ld_t__link            TYPE zbd0t_ty_t_link_key
    , ld_t__dim_list        TYPE zbd00_t_ch_key
    , ld_t__clear_range     TYPE uj0_t_sel
    , ld_t__range           TYPE uj0_t_sel
    , ld_t__param           TYPE zbnlt_t__param
    , ld_t__log_read        TYPE zbd0t_t__log_read
    , ld_t__log_read_dim    TYPE zbd0t_t__log_dimension
    , ld_t__log_write       TYPE zbd0t_t__log_write
    .

    FIELD-SYMBOLS
    : <ld_t__dim_list>      TYPE zcl_bd00_model=>ty_t_dim_list
    , <ld_s__dim_list>      TYPE zcl_bd00_model=>ty_s_dim_list
    , <ld_t__mp_pl>         TYPE ty_mp_pl
    .
  ENDIF.
  IF `CONTEXT`    = `CONTEXT`   .
    CREATE OBJECT lr_o__security.
    ld_s__user-user_id = lr_o__security->d_server_admin_id.
    TRY.
        cl_uj_context=>set_cur_context( i_appset_id = i_v__appset_id is_user = ld_s__user ).
      CATCH cx_uj_obj_not_found.
        RAISE err_appset_id.
    ENDTRY.

    CREATE OBJECT lr_o__rfc_task
      EXPORTING
        num           = 4
        parallel_task = abap_true.
  ENDIF.
  IF `TARGET`     = `TARGET`    .
    SELECT  tg_dimn tg_value sc_dimn sc_value
      FROM  zrb_mp_pl
      INTO CORRESPONDING FIELDS OF TABLE ld_t__mp_pl
           WHERE id_rule = i_v__id_rule
             AND appset  = i_v__appset_id
             AND tg_appl = i_v__tg_appl_id
             AND tg_dimn <> space
             AND sc_appl = i_v__sc_appl_id
          ORDER BY tg_dimn ASCENDING.

    TRY.
        lr_o__model ?= zcl_bd00_model=>get_model( i_appset_id = i_v__appset_id
                                                  i_appl_id   = i_v__tg_appl_id
                                                  i_type_pk   = zbd0c_ty_tab-has_unique_dk ).
      CATCH zcx_bd00_create_obj.
        RAISE err_target_create.
    ENDTRY.

    ASSIGN lr_o__model->gr_t__dimension->* TO  <ld_t__dim_list>.

    LOOP AT <ld_t__dim_list> ASSIGNING <ld_s__dim_list>.

      READ TABLE ld_t__mp_pl
           WITH TABLE KEY tg_dimn = <ld_s__dim_list>-dimension
           ASSIGNING <ld_t__mp_pl>.

      IF sy-subrc = 0.
        IF <ld_t__mp_pl>-tg_value IS NOT INITIAL.

          CASE <ld_s__dim_list>-type.
            WHEN zcl_bd00_application=>cs_dm.

              mac__add_to_const
              : <ld_t__mp_pl>-tg_dimn <ld_t__mp_pl>-tg_value.

              mac__add_to_clear_range
              : <ld_t__mp_pl>-tg_dimn `` `EQ`  <ld_t__mp_pl>-tg_value.

            WHEN zcl_bd00_application=>cs_kf.
              ld_v__koef = <ld_t__mp_pl>-tg_value.
          ENDCASE.

        ELSE.
          SPLIT <ld_t__mp_pl>-sc_dimn AT `.` INTO ld_v__dimension ld_v__attribute.

          mac__add_to_link
          : <ld_s__dim_list>-dimension ld_v__dimension ld_v__attribute.

          mac__add_to_dimlist
          : ld_v__dimension ld_v__attribute.

        ENDIF.
      ELSE.
        mac__add_to_link
        : <ld_s__dim_list>-dimension <ld_s__dim_list>-dimension ``.

        mac__add_to_dimlist
        : <ld_s__dim_list>-dimension ``.

      ENDIF.
    ENDLOOP.

    mac__add_to_range
    : `SCENARIO` ``           `EQ` i_v__scenario
    , `ENTITY`   `FORMAT_D`   `EQ` i_v__format.

    LOOP AT i_t__bpctime INTO ld_v__bpctime.
      mac__add_to_range
      : `TIME` `` `EQ`  ld_v__bpctime.
    ENDLOOP.
  ENDIF.
  IF `SOURCE`     = `SOURCE`    .
    SELECT  tg_dimn tg_value sc_dimn sc_value
      FROM  zrb_mp_pl
      INTO CORRESPONDING FIELDS OF ld_s__mp_pl
           WHERE id_rule = i_v__id_rule
             AND appset  = i_v__appset_id
             AND tg_appl = i_v__tg_appl_id
             AND sc_dimn <> space
             AND sc_appl = i_v__sc_appl_id
           ORDER BY sc_dimn ASCENDING.

      FIND REGEX `^<([A-Z0-9\_]+)>` IN ld_s__mp_pl-sc_value.

      IF sy-subrc = 0.
        ld_v__string = ld_s__mp_pl-sc_value.
        REPLACE ALL OCCURRENCES OF REGEX `(<|>)` IN ld_v__string WITH space.

        SELECT id attr opti value
          FROM  zrb_mp_pl_rl
          INTO CORRESPONDING FIELDS OF ld_s__mp_pl_rl
               WHERE  appset  = i_v__appset_id
               AND    id      = ld_v__string.

          ld_v__dimension = ld_s__mp_pl-sc_dimn.
          IF ld_s__mp_pl_rl-attr = `ID`.
            CLEAR ld_v__attribute.
          ELSE.
            ld_v__attribute = ld_s__mp_pl_rl-attr.
          ENDIF.

          FIND REGEX `^BAS\([A-Z0-9\_]+\)` IN ld_s__mp_pl_rl-value.

          IF sy-subrc = 0.
            REPLACE ALL OCCURRENCES OF REGEX `(^BAS\(|\))` IN  ld_s__mp_pl_rl-value WITH space.
            ld_v__member = cl_ujk_util=>bas( i_dim_name = ld_v__dimension i_member = ld_s__mp_pl_rl-value ).
            SPLIT ld_v__member AT ',' INTO TABLE ld_t__param.
            LOOP AT ld_t__param INTO ld_v__value.

              mac__add_to_range
              : ld_v__dimension ld_v__attribute ld_s__mp_pl_rl-opti ld_v__value.

              IF ld_s__mp_pl-tg_dimn IS NOT INITIAL AND ld_s__mp_pl-tg_value IS INITIAL.
                ld_v__dimension = ld_s__mp_pl-tg_dimn.

                mac__add_to_clear_range
                : ld_v__dimension `` ld_s__mp_pl_rl-opti ld_s__mp_pl_rl-value.

              ENDIF.
            ENDLOOP.
          ELSE.
            mac__add_to_range
            : ld_v__dimension ld_v__attribute ld_s__mp_pl_rl-opti ld_s__mp_pl_rl-value.

            mac__add_to_clear_range
            : ld_v__dimension ld_v__attribute ld_s__mp_pl_rl-opti ld_s__mp_pl_rl-value.

          ENDIF.
        ENDSELECT.
      ELSE.
        SPLIT ld_s__mp_pl-sc_dimn AT `.` INTO ld_v__dimension ld_v__attribute.

        mac__add_to_range
        : ld_v__dimension ld_v__attribute  `EQ` ld_s__mp_pl-sc_value.

      ENDIF.
    ENDSELECT.
    mac__add_to_clear_range
    : `SCENARIO` ``           `EQ` i_v__scenario
    , `ENTITY`   `FORMAT_N`   `EQ` i_v__format.

    LOOP AT i_t__bpctime INTO ld_v__bpctime.
      mac__add_to_clear_range `TIME` `` `EQ`  ld_v__bpctime.
    ENDLOOP.

  ENDIF.
  IF `CLEAR`      = `CLEAR`     .
    TRY.
        CREATE OBJECT lr_o__target
          EXPORTING
            i_appset_id = i_v__appset_id
            i_appl_id   = i_v__tg_appl_id
            it_range    = ld_t__clear_range
            i_type_pk   = zbd0c_ty_tab-std_non_unique_dk
            if_invert   = abap_true.
      CATCH zcx_bd00_create_obj.
        RAISE err_target_create.
    ENDTRY.

    WHILE lr_o__target->next_pack( zbd0c_read_mode-pack ) EQ zbd0c_read_pack .
*      WHILE lr_o__target->next_line( ) EQ zbd0c_found.
*        lr_o__target->math( signeddata = -1 operation = `MUL` ).
*      ENDWHILE.
      lr_o__target->write_back( abap_true ).
    ENDWHILE.
    zcl_bd00_appl_table=>free_all_object( ).
  ENDIF.
  IF `CONTAINERS` = `CONTAINERS`.
    TRY.
        CREATE OBJECT lr_o__target
          EXPORTING
            i_appset_id  = i_v__appset_id
            i_appl_id    = i_v__tg_appl_id
            i_type_pk    = zbd0c_ty_tab-has_unique_dk
            if_auto_save = abap_true
            it_const     = ld_t__const.
      CATCH zcx_bd00_create_obj.
        RAISE err_target_create.
    ENDTRY.

    TRY.
        CREATE OBJECT lr_o__source
          EXPORTING
            i_appset_id   = i_v__appset_id
            i_appl_id     = i_v__sc_appl_id
            it_range      = ld_t__range
            it_dim_list   = ld_t__dim_list
            i_packagesize = i_v__packagesize
            i_type_pk     = zbd0c_ty_tab-std_non_unique_dk.
      CATCH zcx_bd00_create_obj.
        RAISE err_source_create.
    ENDTRY.
  ENDIF.
  IF `RULES`      = `RULES`     .
    CONCATENATE `SOURCE * ` ld_v__koef INTO  ld_s__rules_math-exp.

    ld_s__operand-var    = `SOURCE`.
    ld_s__operand-object = lr_o__source.
    INSERT ld_s__operand INTO TABLE ld_s__rules_math-operand.

    ld_v__rule_assign =
    lr_o__target->set_rule_assign( is_math    = ld_s__rules_math
                                   io_default = lr_o__source
                                   it_link    = ld_t__link
                                   i_mode_add = zbd0c_mode_add_line-collect ).
  ENDIF.
  IF `WORK_CYCLE` = `WORK_CYCLE`.
    WHILE lr_o__source->next_pack( zbd0c_read_mode-pack ) EQ zbd0c_read_pack.
      WHILE lr_o__source->next_line( ) EQ zbd0c_found.
        lr_o__target->rule_assign( ld_v__rule_assign ).
      ENDWHILE.
    ENDWHILE.
    lr_o__target->write_back( ).
  ENDIF.

  CALL METHOD lr_o__source->get_log
    IMPORTING
      e_t__read = ld_t__log_read.

  CALL METHOD lr_o__target->get_log
    IMPORTING
      e_t__write = ld_t__log_write.



  FIELD-SYMBOLS
  : <ld_s__log_read>  LIKE LINE OF ld_t__log_read
  , <ld_s__log_write> LIKE LINE OF ld_t__log_write
  .

  LOOP AT ld_t__log_read ASSIGNING <ld_s__log_read>.
    ADD <ld_s__log_read>-sup_rec TO num_read.
  ENDLOOP.

  LOOP AT ld_t__log_write ASSIGNING <ld_s__log_write>.
    ADD <ld_s__log_write>-status_records-nr_submit TO num_write-nr_submit.
    ADD <ld_s__log_write>-status_records-nr_fail TO num_write-nr_fail.
    ADD <ld_s__log_write>-status_records-nr_success TO num_write-nr_success.

    APPEND LINES OF <ld_s__log_write>-message TO e_message.
  ENDLOOP.

  SORT e_message.
  DELETE ADJACENT DUPLICATES FROM e_message.

  zcl_bd00_appl_table=>free_all_object( ).

*    e_t__read     = ld_t__log_read
*    e_t__read_dim = ld_t__log_read_dim
*--------------------------------------------------------------------*
ENDFUNCTION.

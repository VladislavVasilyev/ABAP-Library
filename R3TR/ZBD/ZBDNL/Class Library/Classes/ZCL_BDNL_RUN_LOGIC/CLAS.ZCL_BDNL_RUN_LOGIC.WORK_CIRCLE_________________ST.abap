method WORK_CIRCLE_________________ST.

  data
  : lr_t__assign         type hashed table of  ref to zcl_bd00_appl_table with unique default key
  , ld_v__tablename      type zbnlt_v__tablename
  , lr_s__master         type ref to zbnlt_s__containers
  , ld_v__turn           type i
  , ld_v__qlines         type i
  , ld_s__rules          type ty_s__rules
  , ld_t__rules          type ty_t__rules
  , ld_v__cnt            type i
  , ld_v__packsize       type i
  , ld_v__packsize_str   type string
  , ld_v__packstart      type tzntstmpl
  , ld_v__packend        type tzntstmpl
  , ld_v__duration       type string
  , ld_v__nr_pack        type string
  .


  field-symbols
  : <ld_s__search>       type zbnlt_s__search
  , <ld_s__tablefordown> type zbnlt_s__assign
  , <ld_s__assign_obj>   like line of lr_t__assign
  , <ld_s__containers>   type zbnlt_s__containers
  , <ld_s__master>       type zbnlt_s__containers
  .

  clear
  : gd_t__for_containers
  , gd_s__rules
  .

*--------------------------------------------------------------------*
* Rules
*--------------------------------------------------------------------*
  ld_v__qlines = lines( i_s__for-rules ).

  if ld_v__qlines > 0.
    message s040(zbdnl).
  endif.

  do  ld_v__qlines times.
    clear ld_s__rules.
    add 1 to ld_v__turn.

    ld_s__rules-search = create_search_rule( i_s__for = i_s__for i_v__turn = ld_v__turn ).
    ld_s__rules-n_search = lines( ld_s__rules-search ).

    call method create_assign_rule
      exporting
        i_s__for              = i_s__for
        i_v__turn             = ld_v__turn
      importing
        e_t__assign           = ld_s__rules-assign
        e_t__assign_not_found = ld_s__rules-assign_not_found.

    ld_s__rules-n_assign = lines( ld_s__rules-assign ).
    ld_s__rules-n_assign_not_found = lines( ld_s__rules-assign_not_found ).

    append ld_s__rules to ld_t__rules.
  enddo.

  if ld_v__qlines > 0.
    message s050(zbdnl).
  endif.

*--------------------------------------------------------------------*
  read table gd_t__for_containers
       with key tablename = i_s__for-tablename
       assigning <ld_s__master>.

  if sy-subrc ne 0.
    lr_s__master = create_container( i_v__tablename = i_s__for-tablename i_s__for = i_s__for ).
    assign lr_s__master->* to <ld_s__master>.
  endif.

  if <ld_s__master>-init ne abap_true.
    message s046(zbdnl) with <ld_s__master>-tablename.

    while <ld_s__master>-object->next_pack( <ld_s__master>-read_mode ) eq zbd0c_read_pack.

      add 1 to ld_v__cnt.
      get time stamp field ld_v__packstart.
      ld_v__packsize = <ld_s__master>-object->get_packsize( ).

*--------------------------------------------------------------------*
* MAIN
*--------------------------------------------------------------------*
      while <ld_s__master>-object->next_line( ) eq zbd0c_found.
        loop at ld_t__rules into gd_s__rules.
          search( 1 ).
        endloop.
      endwhile.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* LOG
*--------------------------------------------------------------------*
      get time stamp field ld_v__packend.
      call method convert_time
        exporting
          i_v__start      = ld_v__packstart
          i_v__end        = ld_v__packend
        importing
          e_v__delta_time = ld_v__duration.

      ld_v__packsize_str = get_nr_pack( i_v__nr_pack = ld_v__packsize i_v__size = 8 ).
      ld_v__nr_pack = get_nr_pack(  i_v__nr_pack = ld_v__cnt i_v__size = 4 ).
      message s029(zbdnl) with ld_v__nr_pack ld_v__packsize_str ld_v__duration.
*--------------------------------------------------------------------*

      check <ld_s__master>-read_mode = zbd0c_read_mode-full.
      exit.
    endwhile.

    message s050(zbdnl).
    <ld_s__master>-init = abap_true.


  else.
    message s046(zbdnl) with <ld_s__master>-tablename.
    get time stamp field ld_v__packstart.
    ld_v__packsize = <ld_s__master>-object->get_packsize( ).

*--------------------------------------------------------------------*
* MAIN
*--------------------------------------------------------------------*
    while <ld_s__master>-object->next_line( ) eq zbd0c_found.
      loop at ld_t__rules into gd_s__rules.
        search( 1 ).
      endloop.
*--------------------------------------------------------------------*

    endwhile.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* LOG
*--------------------------------------------------------------------*
    get time stamp field ld_v__packend.
    call method convert_time
      exporting
        i_v__start      = ld_v__packstart
        i_v__end        = ld_v__packend
      importing
        e_v__delta_time = ld_v__duration.

    ld_v__packsize_str = get_nr_pack( i_v__nr_pack = ld_v__packsize i_v__size = 8 ).
    message s029(zbdnl) with `FULL` ld_v__packsize_str ld_v__duration.
    message s050(zbdnl).
*--------------------------------------------------------------------*
  endif.

*--------------------------------------------------------------------*
* Сохранение остатков для таблиц для сохранения
*--------------------------------------------------------------------*
  loop at ld_t__rules into ld_s__rules.
    loop at ld_s__rules-assign assigning <ld_s__tablefordown>
      where command = zblnc_keyword-tablefordown.
      insert <ld_s__tablefordown>-object into table lr_t__assign.
    endloop.

    loop at ld_s__rules-assign_not_found assigning <ld_s__tablefordown>
      where command = zblnc_keyword-tablefordown.
      insert <ld_s__tablefordown>-object into table lr_t__assign.
    endloop.
  endloop.

  loop at lr_t__assign assigning <ld_s__assign_obj>.
    <ld_s__assign_obj>->write_back( abap_true ).
    read table gd_t__containers
       with key object = <ld_s__assign_obj>
       assigning <ld_s__containers>.
    <ld_s__containers>-clear = abap_true.
  endloop.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* $EXITFOR
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* $COMMIT
*--------------------------------------------------------------------*
  message s054(zbdnl).
  loop at i_s__for-commit into ld_v__tablename.
    read table gd_t__containers
       with key tablename = ld_v__tablename
       assigning <ld_s__containers>.

    if sy-subrc = 0.
      ld_v__packsize = <ld_s__containers>-object->get_packsize( ).
      ld_v__packsize_str = get_nr_pack( i_v__nr_pack = ld_v__packsize i_v__size = 8 ).
      <ld_s__containers>-object->write_back( ).
      message s055(zbdnl) with <ld_s__containers>-tablename ld_v__packsize_str.
    endif.

  endloop.
  message s050(zbdnl).

*--------------------------------------------------------------------*
* $CLEAR
*--------------------------------------------------------------------*
  loop at i_s__for-clear into ld_v__tablename.
    read table gd_t__containers
       with key tablename = ld_v__tablename
       assigning <ld_s__containers>.
    if sy-subrc = 0.
      <ld_s__containers>-object->clear( ).
      <ld_s__containers>-clear = abap_true.
    endif.
  endloop.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
  zcl_bd00_rfc_task=>wait_end_all_task( ). " ожидание завершения всех RFC

endmethod.

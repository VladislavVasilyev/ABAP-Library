method work_circle_________________nv.

  data
  : lr_t__assign                  type hashed table of  ref to zcl_bd00_appl_table with unique default key
  , ld_v__tablename               type zbnlt_v__tablename
  , lr_s__master                  type ref to zbnlt_s__containers
  , ld_v__turn                    type i
  , ld_v__qlines                  type i
  , ld_s__rules                   type ty_s__rules
  , ld_t__rules                   type ty_t__rules
  , ld_v__cnt                     type i
  , ld_v__packsize                type i
  , ld_v__packsize_str            type string
  , ld_v__packstart               type tzntstmpl
  , ld_v__packend                 type tzntstmpl
  , ld_v__duration                type string
  , ld_v__nr_pack                 type string
*  , lr_o__container               type ref to zcl_bdnl_container
  , lr_o__main                    type ref to zcl_bdnl_container
  , lr_o__container               type ref to zcl_bdnl_container
  .


  field-symbols
  : <ld_s__search>                type zbnlt_s__search
  , <ld_s__tablefordown>          type zbnlt_s__assign
  , <ld_s__assign_obj>            like line of lr_t__assign
  , <ld_s__containers>            type zbnlt_s__containers
*  , <ld_s__master>                type zbnlt_s__containers
  .

  clear
  : gd_t__for_containers1
  , gd_s__rules
  .

  zcl_bdnl_container=>clear_for_reestr( ).

*--------------------------------------------------------------------*
* Create master table
*--------------------------------------------------------------------*
  lr_o__main  ?= zcl_bdnl_container=>create_container(
                            tablename    = i_s__for-tablename
                            package_size = i_s__for-packagesize
                            f_master     = abap_true ).
*--------------------------------------------------------------------*




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


  if lr_o__main->gd_f__init ne abap_true.
    message s046(zbdnl) with lr_o__main->gd_v__tablename.

    while lr_o__main->next_pack( ) eq zbd0c_read_pack.

      add 1 to ld_v__cnt.
      get time stamp field ld_v__packstart.
      ld_v__packsize = lr_o__main->gr_o__container->get_packsize( ).

*--------------------------------------------------------------------*
* MAIN
*--------------------------------------------------------------------*
      while lr_o__main->next_line( ) eq zbd0c_found.
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

      check lr_o__main->gd_v__read_mode = zbd0c_read_mode-full.
      exit.
    endwhile.

    message s050(zbdnl).
  else.
    message s046(zbdnl) with lr_o__main->gd_v__tablename.
    get time stamp field ld_v__packstart.
    ld_v__packsize = lr_o__main->gr_o__container->get_packsize( ).

*--------------------------------------------------------------------*
* MAIN
*--------------------------------------------------------------------*
    while lr_o__main->next_line( ) eq zbd0c_found.
      loop at ld_t__rules into gd_s__rules.
        search( 1 ).
      endloop.
*--------------------------------------------------------------------*

    endwhile.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Актуализировать записи
*--------------------------------------------------------------------*
    zcl_bdnl_container=>actual_ctables( ).


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

    lr_o__container ?= zcl_bdnl_container=>get_container_object( <ld_s__assign_obj> ).

    if lr_o__container is bound .
      lr_o__container->set_clear( ).
    endif.

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

    lr_o__container ?= zcl_bdnl_container=>get_container( ld_v__tablename ).

    if lr_o__container is bound.
      ld_v__packsize = lr_o__container->gr_o__container->get_packsize( ).
      ld_v__packsize_str = get_nr_pack( i_v__nr_pack = ld_v__packsize i_v__size = 8 ).
      lr_o__container->gr_o__container->write_back( ).
      message s055(zbdnl) with <ld_s__containers>-tablename ld_v__packsize_str.
    endif.

  endloop.
  message s050(zbdnl).

*--------------------------------------------------------------------*
* $CLEAR
*--------------------------------------------------------------------*
  loop at i_s__for-clear into ld_v__tablename.

    lr_o__container ?= zcl_bdnl_container=>get_container( ld_v__tablename ).

    if lr_o__container is bound.
      lr_o__container->gr_o__container->clear( ).
      lr_o__container->set_clear( ).
    endif.
  endloop.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
  zcl_bd00_rfc_task=>wait_end_all_task( ). " ожидание завершения всех RFC

endmethod.

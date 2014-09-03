method get_t_param.
*--------------------------------------------------------------------*
* обработка it_param
* заполнение поля gt_param
* HASHKEY
* HASHVALUE
*--------------------------------------------------------------------*
  data
      : ls_param          like line of gt_param
      , lt_value          type table of uj_large_string
      , ls_value          like line of lt_value
      , ls_appl_range     like line of dt_appl_range
      , ls_range          type line of uj0_t_sel
      , lv_filter_attr    type string
      , lv_filter_val     type string
      , lt_sel            type uj0_t_sel
      , ls_sel            like line of lt_sel
      , ls_str            type string
      , ls_str1            type string
      , offset            type i
      , length            type i
      .

  field-symbols
      : <ls_param>     like line of it_param
      , <ls_appl_rang> like line of dt_appl_range
      .

  loop at it_param
    into ls_param.
    condense ls_param-val no-gaps.
    find regex `BAS\(([A-Za-z0-9\.\,\s]+)\)` in ls_param-val ignoring case match length length match offset offset.

    if sy-subrc <> 0.

      if ls_param-key = cs-msgbox.
        insert ls_param into table gt_param.
        continue.
      endif.

      split ls_param-val at ',' into table lt_value.

      loop at lt_value
        into ls_param-val.

        check not ls_param-key = ls_param-val.

        insert ls_param into table gt_param.
      endloop.

    else.
      ls_str = ls_param-val+offset(length).

      replace regex `BAS\(` in ls_str with ``.
      replace regex `\)`    in ls_str with ``.

      split ls_str at ',' into table lt_value.

      loop at lt_value
        into ls_str.

        concatenate `BAS(` ls_str `)` into ls_str.
        ls_str1 = ls_param-val.

        replace regex `BAS\(([A-Za-z0-9\.\,\s]+)\)` in ls_str1 with ls_str.
        ls_param-val = ls_str1.

        insert ls_param into table gt_param.
      endloop.
    endif.
  endloop.

**********************************************************************
* Извлечение параметров
**********************************************************************
  dv_application_id          = i_appl_id.   " имя приложения
  dv_appset_id               = i_appset_id. " имя набора прилодожения

  ds_read_pack-first_call    = abap_true.   " флаг первого вызова процедуры чтения
  ds_read_pack-rfc_wait_read = abap_true.   " флаг ожидания окончания RFC вызова


  " характеристики пользователя
  data lo_uj_context  type ref to if_uj_context.
  data lt_variant_paraters type ujd_th_value.
  data ls_variant_paraters type line of ujd_th_value.

  lo_uj_context ?= cl_uj_context=>get_cur_context( ).
  move-corresponding lo_uj_context->ds_user to ds_user.

  select single email
         from   uje_user
         into   ds_user-email
         where  appset_id = i_appset_id and
                user_id   = ds_user-user_id.

  cl_ujd_package_context=>get_variant_paras(
          importing eht_variant_paras = lt_variant_paraters ).

  read table lt_variant_paraters
       with table key fieldname = cs-package
       into ls_variant_paraters.

  if sy-subrc = 0.
    ds_user-package_id = ls_variant_paraters-value.
  endif.

**********************************************************************
* CLASS. Имя метода для запуска, расчета данных.
**********************************************************************
  read table gt_param
       with key key = cs-method
       into ls_param.

  if sy-subrc = 0.
    split ls_param-val at `~` into ds_method-class ds_method-name.

    translate ds_method-class to upper case.
    translate ds_method-name  to upper case.
  else.
    mac__raise_logistics ex_par_class '' '' '' '' .
  endif.

  if ds_method-name is initial.
    mac__raise_logistics ex_par_method '' '' '' '' .
  endif.

**********************************************************************
* METHOD. Имя метода для запуска, расчета данных.
**********************************************************************
*  read table gt_param
*       with key key = cs-method
*       into ls_param.
*
*  if sy-subrc = 0.
*    ds_method-execute = ds_method-name    = ls_param-val.
*
*    translate ds_method-name to upper case.
*  else.
*    mac__raise_logistics ex_par_method '' '' '' '' .
*  endif.
*--------------------------------------------------------------------*

**********************************************************************
* LOG. Управление логами
**********************************************************************
  read table gt_param
       with key key = cs-log
       into ls_param.

  if sy-subrc = 0 and ls_param-val = 'ON'.
    ds_method-f_log = abap_true.
  endif.
*--------------------------------------------------------------------*

**********************************************************************
* TASK. Количество паралельных процессов
**********************************************************************
  read table gt_param
     with key key = cs-task
     into ls_param.

  if sy-subrc = 0.
    ds_method-nr_task = ls_param-val.
  else.
    ds_method-nr_task = 0.
  endif.

  create object do_rfc_task
    exporting
      num = ds_method-nr_task.
*--------------------------------------------------------------------*

**********************************************************************
* CLEAR. Извлечение имени приложения для удаления данных
**********************************************************************
  if ds_method-name = 'CLEAR'.
    read table gt_param
         with key key = cs-clear_appl
         into ls_param.

    if sy-subrc = 0.
      dv_application_id = ls_param-val.
    endif.
  endif.
*--------------------------------------------------------------------*

**********************************************************************
* DEBUG. Если 'ON' то зациклить
**********************************************************************
  read table gt_param
       with key key = cs-debug
       into ls_param.

  if sy-subrc = 0 and ls_param-val = 'ON'.
    ds_method-f_debug = abap_true.
  endif.
*--------------------------------------------------------------------*

**********************************************************************
* NORUN. Отмена запуска
**********************************************************************
  read table gt_param
      with key key = cs-norun
      into ls_param.

  if sy-subrc = 0 and ls_param-val = 'ON'.
    ds_method-f_norun = abap_true.
  endif.
*--------------------------------------------------------------------*

**********************************************************************
* PACKAGESIZE. Размер пакета
**********************************************************************
  read table gt_param
       with key key = cs-packagesize
       into ls_param.

  if sy-subrc = 0.
    ds_method-packagesize = ls_param-val.
  else.
    ds_method-packagesize = 30000.
  endif.
*--------------------------------------------------------------------*

**********************************************************************
* MAIL. Отправлять почту
**********************************************************************
  read table gt_param
       with key key = cs-mail
       into ls_param.

  if sy-subrc = 0 and ls_param-val = 'ON'.
    ds_method-f_mail = abap_true.
  endif.
*--------------------------------------------------------------------*

**********************************************************************
* MSGBOX
**********************************************************************
  read table gt_param
        with key key = cs-msgbox
        into ls_param.

  if sy-subrc = 0.
    ds_method-msgbox = ls_param-val.
  endif.

*--------------------------------------------------------------------*

**********************************************************************
* get filter for appl
**********************************************************************
  loop at gt_param
    into ls_param
    where key cp 'FILTER.*'.

    ls_range-sign   = 'I'.
    ls_range-option = 'EQ'.

    replace first occurrence of 'FILTER.' in ls_param-key with space.

    split ls_param-key  at '.' into table lt_value.

    read table lt_value index 1 into ls_value.           "appl

    read table dt_appl_range
         with table key filter_key = ls_value
         assigning <ls_appl_rang>.

    if sy-subrc <> 0.
      assign ls_appl_range to <ls_appl_rang>.
      <ls_appl_rang>-filter_key = ls_value.
    endif.

    read table lt_value index 2 into ls_range-dimension. " dim

    split ls_param-val  at '=' into lv_filter_attr lv_filter_val.

    if lv_filter_attr is not initial and
       lv_filter_attr <> uja00_cs_attr-id.
      ls_range-attribute = lv_filter_attr.
    endif.

    find regex `BAS\(([A-Za-z0-9\_\.\,\s]+)\)` in lv_filter_val ignoring case.

    if sy-subrc <> 0.

      split lv_filter_val at '|' into table lt_value.

      loop at lt_value
        into ls_value.
        ls_range-low = ls_value.
        append ls_range to <ls_appl_rang>-t_range.
      endloop.

    else.
      clear lt_sel.
      find regex '([A-Za-z0-9\_]+)~BAS\(([A-Za-z0-9\_\.\,\s]+)\)' in lv_filter_val ignoring case.
      if sy-subrc = 0.
        split lv_filter_val at `~` into ls_sel-dimension lv_filter_val.
        condense
        : lv_filter_val      no-gaps
        , ls_sel-dimension no-gaps.
      else.
        ls_sel-dimension  = ls_range-dimension.
      endif.

      ls_sel-sign       = 'I'.
      ls_sel-option     = 'EQ'.
      ls_sel-low        = lv_filter_val.

      append ls_sel to lt_sel.

      call function 'ZBW_EXPLAIN_SELECTION'
        exporting
          i_appset_id = i_appset_id
          i_appl_id   = i_appl_id
        changing
          ct_sel      = lt_sel.

      loop at lt_sel
        into ls_sel.
        ls_range-low = ls_sel-low.
        append ls_range to <ls_appl_rang>-t_range.
      endloop.
    endif.


    sort  <ls_appl_rang>-t_range ascending." by di  attribute low.
    delete adjacent duplicates from <ls_appl_rang>-t_range comparing all fields.
    insert <ls_appl_rang> into table dt_appl_range.

    clear: ls_appl_range, lv_filter_attr, lv_filter_val, ls_range.
    unassign <ls_appl_rang>.

  endloop.
endmethod.

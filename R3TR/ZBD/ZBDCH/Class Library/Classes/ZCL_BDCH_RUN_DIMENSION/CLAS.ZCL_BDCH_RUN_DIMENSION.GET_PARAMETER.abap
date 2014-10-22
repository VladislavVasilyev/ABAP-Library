method get_parameter.

  data
  : l_value               type ujd_runparam-value
  , l_value1              type string
  , l_value2              type string
  , l_para                type ujd_runparam-param_name
  , l_name                type rspc_variant
  , ld_t__script          type table of string
  , ld_t__path            type table of string
  , ld_v__cnt             type i value 0
  , ld_s__script          type zcl_bdnl_badi_params=>ty_s__script
  , ld_v__string          type string
  , ld_v__st              type string
  , ld_v__txt             type string
  .

  field-symbols
  : <ld_v__script>        type string
  , <ld_v__path>          type string.

*  zcl_debug=>stop_program( ).

  if `DEBUG`           = `DEBUG`.
    l_para = `DEBUG`.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.

    if l_value = `ON`.
      gd_f__debug = abap_true.
    else.
      gd_f__debug = abap_false.
    endif.
  endif.
  if `NORUN`           = `NORUN`.
*    l_para = `NORUN`.
*    try .
*        call method do_config->if_ujd_config~get_parameter
*          exporting
*            i_parameter       = l_para
*          importing
*            e_parameter_value = l_value.
*      catch cx_ujd_datamgr_error.
*        l_value = ''.
*    endtry.
*
*    if l_value = `X`.
*      gd_f__norun = abap_true.
*    else.
*      gd_f__norun = abap_false.
*    endif.
  endif.
  if `PARALLEL_TASK`   = `PARALLEL_TASK`.
*    l_para = `PARALLEL_TASK`.
*    try .
*        call method do_config->if_ujd_config~get_parameter
*          exporting
*            i_parameter       = l_para
*          importing
*            e_parameter_value = l_value.
*
*        condense l_value no-gaps.
*        split l_value at `|` into l_value1 l_value2 .
*
*        if l_value1 = `ON`.
*          gd_f__parallel_task = abap_true.
*        else.
*          gd_f__parallel_task = abap_false.
*        endif.
*
*        gd_v__num_tasks = l_value2.
*
*      catch cx_ujd_datamgr_error.
*        gd_f__parallel_task = abap_false.
*        gd_v__num_tasks     = zblnc_default_num_task.
*    endtry.
*
*    l_value2 = gd_v__num_tasks.
  endif.
  if `TIME_ID`         = `TIME_ID`.
*    l_para = `TIME_ID`.
*    try .
*        call method do_config->if_ujd_config~get_parameter
*          exporting
*            i_parameter       = l_para
*          importing
*            e_parameter_value = l_value.
*      catch cx_ujd_datamgr_error.
*        l_value = ''.
*    endtry.
*    gd_v__time_id = get_value_rspc( l_value ).
  endif.
  if `SAPPSET`         = `SAPPSET`.
    l_para = ujd0_cs_task_parameter-appset_id.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.

    gd_v__appset_id = l_value.
  endif.
  if `DIMENSION`         = `DIMENSION`.
    data ld_v__dimlist   type string.
    data ld_v__checklist type string.
    data ld_t__checklist type standard table of string.


    l_para = `DIMENSION`.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.

    replace all occurrences of `"` in l_value with space.
    condense l_value no-gaps.

    split l_value at `|` into ld_v__dimlist ld_v__checklist.
    split ld_v__dimlist  at `,` into table gd_t__dimension.
    split ld_v__checklist at `,` into table ld_t__checklist.

    if ld_v__dimlist = `<ALL>`.
      select dimension
        from uja_dimension
        into table gd_t__dimension
        where appset_id = gd_v__appset_id.
    else.
      loop at ld_t__checklist into ld_v__checklist
          where table_line = 0.
        delete gd_t__dimension index sy-tabix.
      endloop.
    endif.

*    gd_v__dimension = l_value.
  endif.
  if `SAPP`            = `SAPP`.
    l_para = ujd0_cs_task_parameter-application_id.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    gd_v__appl_id = l_value.
  endif.
  if `SUSER`           = `SUSER`.
    l_para = ujd0_cs_task_parameter-user_id.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    gd_v__user_id = l_value.
  endif.
  if `MASTERFILE` = `MASTERFILE`.
    l_para = `MASTERFILE`.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    if l_value = `ON`.
      gd_f__masterfile = abap_true.
    else.
      gd_f__masterfile = abap_false.
    endif.
  endif.
  if `SELECTION`       = `SELECTION`.
    l_para = ujd0_cs_task_parameter-selection.
    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    gd_v__selection = l_value.
    if gd_v__selection = `%SELECTION%`.
      clear gd_v__selection..
    endif.
  endif.
  if `MEMBERSELECTION` = `MEMBERSELECTION`.
    try .
        l_para = ujd0_cs_task_parameter-memberselection.
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    gd_v__memberselection = l_value.
  endif.

  if `MODE` = `MODE`.
    try .
        l_para = `MODE`.
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    case l_value.
      when cs_save.
        gd_v__mode = cs_save.
      when cs_process.
        gd_v__mode = cs_process.
    endcase.
  endif.



  if `REPLACEPARAM`    = `REPLACEPARAM`.
    l_para = ujd0_cs_task_parameter-tab.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    gd_s__badi_param-splitter = l_value.

    l_para = ujd0_cs_task_parameter-equ.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    gd_s__badi_param-equal = l_value.

    l_para = ujd0_cs_task_parameter-replaceparam.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    gd_s__badi_param-parameter = l_value.
  endif.
  if `PACKAGE_ID`      = `PACKAGE_ID`.
    l_para = ujd0_cs_task_parameter-package_id.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    gd_v__package_id = l_value.
  endif.
  if `SENDMAIL`        = `SENDMAIL`.
    l_para = `SENDMAIL`.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.

    condense l_value no-gaps.
    split l_value at `|` into gd_v__sendmail gd_f__logmail.
  endif.

  " Принт парам
  message s035(zbdnl).
  mprint> `Variant Parameters:`.
  mprint> `---`.

  pprint> `APPSET_ID`      gd_v__appset_id.
  pprint> `APPLICATION_ID` gd_v__appl_id.
  pprint> `USER_ID`        gd_v__user_id.

  " Печать запускающего процесса

  if gd_v__package_id  is not initial.
    pprint> `PACKAGE_ID` gd_v__package_id.
  endif.

  st> gd_f__debug           ld_v__st.
  pprint> `DEBUG`           ld_v__st.

  message s035(zbdnl).

endmethod.

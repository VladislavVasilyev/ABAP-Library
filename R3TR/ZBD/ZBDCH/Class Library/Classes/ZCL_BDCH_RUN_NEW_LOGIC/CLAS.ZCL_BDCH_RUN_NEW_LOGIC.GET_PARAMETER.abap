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

  if `VS`           = `VS`.
    l_para = `VS`.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = `OLD`.
    endtry.

    case l_value.
      when `STABLE`.
        cd_v__version = `STABLE`.
      when others.
        cd_v__version = l_value.
    endcase.
  endif.

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
    l_para = `NORUN`.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.

    if l_value = `X`.
      gd_f__norun = abap_true.
    else.
      gd_f__norun = abap_false.
    endif.
  endif.
  if `PARALLEL_TASK`   = `PARALLEL_TASK`.
    l_para = `PARALLEL_TASK`.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.

        condense l_value no-gaps.
        split l_value at `|` into l_value1 l_value2 .

        if l_value1 = `ON`.
          gd_f__parallel_task = abap_true.
        else.
          gd_f__parallel_task = abap_false.
        endif.

        gd_v__num_tasks = l_value2.

      catch cx_ujd_datamgr_error.
        gd_f__parallel_task = abap_false.
        gd_v__num_tasks     = zblnc_default_num_task.
    endtry.

    l_value2 = gd_v__num_tasks.
  endif.
  if `TIME_ID`         = `TIME_ID`.
    l_para = `TIME_ID`.
    try .
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = l_para
          importing
            e_parameter_value = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    gd_v__time_id = get_value_rspc( l_value ).
  endif.
  if `SAPPSET`         = `SAPPSET`.
    if gv_f__rspc = abap_true.
      l_para = `APPSET_ID`.
    else.
      l_para = ujd0_cs_task_parameter-appset_id.
    endif.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    d_appset_id = get_value_rspc( l_value ).
  endif.
  if `SAPP`            = `SAPP`.
    if gv_f__rspc = abap_true.
      l_para = `APPL_ID`.
    else.
      l_para = ujd0_cs_task_parameter-application_id.
    endif.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    d_appl_id = get_value_rspc( l_value ).
  endif.
  if `LOGICFILENAME`   = `LOGICFILENAME`.
    l_para = ujd0_cs_task_parameter-logicname.
    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.

    if l_value is initial.
      l_name = l_para.
      raise exception type cx_ujd_datamgr_error
      exporting
        textid = cx_ujd_datamgr_error=>ex_get_para_failed
        variant_name = l_name.
    endif.

    condense l_value no-gaps.
    d_logic_file_path = l_value.


*--------------------------------------------------------------------*
* script logic
*--------------------------------------------------------------------*
    split d_logic_file_path at `|` into table ld_t__script.

    loop at ld_t__script assigning <ld_v__script>.
      split <ld_v__script> at `/` into table ld_t__path.

      add 1 to ld_v__cnt.
      ld_s__script-order = ld_v__cnt.
      ld_s__script-run = abap_true.

      loop at ld_t__path assigning <ld_v__path>.
        case lines( ld_t__path ).
          when 1.
            ld_s__script-appset_id = d_appset_id.
            ld_s__script-appl_id = d_appl_id.
            ld_s__script-script = <ld_v__path>.
          when 2.
            if sy-tabix = 1.
              ld_s__script-appset_id = d_appset_id.
              ld_s__script-appl_id = <ld_v__path>.
            elseif sy-tabix = 2.
              ld_s__script-script = <ld_v__path>.
            endif.
          when 3.
            case sy-tabix.
              when 1.
                ld_s__script-appset_id = <ld_v__path>.
              when 2.
                ld_s__script-appl_id = <ld_v__path>.
              when 3.
                ld_s__script-script = <ld_v__path>.
            endcase.
        endcase.
      endloop.

      append ld_s__script to gd_t__logic_file.
    endloop.
  endif.
  if `SUSER`           = `SUSER`.
    if gv_f__rspc = abap_true.
      l_para = `USER_ID`.
    else.
      l_para = ujd0_cs_task_parameter-user_id.
    endif.

    call method do_config->if_ujd_config~get_parameter
      exporting
        i_parameter       = l_para
      importing
        e_parameter_value = l_value.
    d_user_id = get_value_rspc( l_value ).
  endif.
  if `SELECTION`       = `SELECTION`.
    if not  gv_f__rspc eq abap_true.
      l_para = ujd0_cs_task_parameter-selection.
      call method do_config->if_ujd_config~get_parameter
        exporting
          i_parameter       = l_para
        importing
          e_parameter_value = l_value.
      d_selection = l_value.

    else.
      get_selection_rspc( gd_v__rspc_var ).
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
        d_memberselection = l_value.
      catch cx_ujd_datamgr_error.
        l_value = ''.
    endtry.
    d_memberselection = l_value.
  endif.
  if `REPLACEPARAM`    = `REPLACEPARAM`.
    if not gv_f__rspc eq abap_true.
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
      ds_badi_param-splitter = l_value.

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
      ds_badi_param-equal = l_value.

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
      ds_badi_param-parameter = l_value.
    else.
      get_replaceparam_rspc( gd_v__rspc_var ).
    endif.
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
    d_package_id = l_value.
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
    split l_value at `|` into d_sendmail dv_f__logmail.
  endif.

  " Принт парам
  message s035(zbdnl).
  mprint> `Variant Parameters:`.
  mprint> `---`.

  pprint> `APPSET_ID`      d_appset_id.
  pprint> `APPLICATION_ID` d_appl_id.
  pprint> `USER_ID`        d_user_id.
  pprint> `LOGIC NAME`     d_logic_file_path.

  " Печать запускающего процесса
  if not gv_f__rspc eq abap_true.
    if d_package_id  is not initial.
      pprint> `PACKAGE_ID` d_package_id.
    endif.
  else.
    select single txtlg " цепочка
           into ld_v__txt
           from rspcchaint
           where chain_id = gd_v__chain_id
             and objvers = `A`.

    message s020(zmx_bdch_badi) with gd_v__chain_id ld_v__txt.

    select single txtlg " вариант
            into ld_v__txt
            from rspcvariantt
            where variante = gd_v__rspc_var
              and objvers = `A`
              and type  = gd_v__rspc_type.

    message s021(zmx_bdch_badi) with gd_v__rspc_var ld_v__txt.
  endif.

  if gd_v__time_id is not initial.
    pprint> `TIME_ID` gd_v__time_id.
  endif.

  st> gd_f__parallel_task   ld_v__st.
  pprint> `Parallel task`   ld_v__st.

  l_value =   gd_v__num_tasks.
  pprint> `Number of parallel tasks`   l_value.

  st> gd_f__debug           ld_v__st.
  pprint> `DEBUG`           ld_v__st.

  st> gd_f__norun           ld_v__st.
  pprint> `NORUN`           ld_v__st.

  message s035(zbdnl).

endmethod.

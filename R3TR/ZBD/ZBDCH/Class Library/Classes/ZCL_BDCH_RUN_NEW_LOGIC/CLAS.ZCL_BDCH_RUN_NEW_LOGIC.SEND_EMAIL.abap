method send_email.

  data " data declarations
  : ls_mailsubject     type sodocchgi1
  , lt_mailrecipients  type standard table of somlrec90
  , ls_mailrecipients  type somlrec90
  , lt_mailtxt         type standard table of soli
  , lt_searchmailtxt   type standard table of soli
  , ls_mailtxt         type soli
  , time               type string
  , lo_logger          type ref to cl_ujd_logger
  , lv_buf             type string
*  , lv_hor_tab         type string
  , ld_v__mail         type uje_user-email
  , ld_t__mail         type table of string
  , ld_v__start_date   type string
  , ld_v__start_time   type string
  , ld_v__delta_time   type string
*  , ld_v__str          type string
*  , ld_v__value        type c length 20
*  , ld_v__cnt          type i
  , ld_v__txt          type string
  , ld_v__theme        type string
  .

  data
  : ls_message         type ujd_s_value
  , lt_value           type table of string
  , lv_lenght          type i
  , lv_offset          type i
  .

  field-symbols
*  : <ls_mailtxt>       type soli
*  : <ld_s__value>      type string
  : <ld_s__message>    type uj0_s_message
  , <ld_v__mail>       type string
  .

  select low
    from tvarvc
    into table ld_t__mail
    where name = `ZSENDEMAIL`.

  select single email
       from   uje_user
       into   ld_v__mail
       where  appset_id = d_appset_id and
              user_id   = d_user_id.

  check sy-subrc = 0 or ld_t__mail is not initial.

**********************************************************************
* Заголовок письма
**********************************************************************
  if not gv_f__rspc eq abap_true.
    lv_buf = hor_tab( in = d_package_id n = 3 ).
    message e007(zmx_bdch_badi) into ls_mailtxt with lv_buf.
    append ls_mailtxt to lt_mailtxt.
  else.
    select single txtlg " цепочка
           into ld_v__txt
           from rspcchaint
           where chain_id = gd_v__chain_id
             and objvers = `A`.

    ld_v__theme = gd_v__chain_id.

    lv_buf = hor_tab( in = gd_v__chain_id n = 2 ).
    message e020(zmx_bdch_badi) into ls_mailtxt with lv_buf ld_v__txt.
    append ls_mailtxt to lt_mailtxt.

    select single txtlg " цепочка
            into ld_v__txt
            from rspcvariantt
            where variante = gd_v__rspc_var
              and objvers = `A`
              and type  = gd_v__rspc_type.

    concatenate ld_v__theme ` -> ` gd_v__rspc_var into ld_v__theme.

    lv_buf = hor_tab( in = gd_v__rspc_var n = 1 ).
    message e021(zmx_bdch_badi) into ls_mailtxt with lv_buf ld_v__txt.
    append ls_mailtxt to lt_mailtxt.
  endif.

  lv_buf = hor_tab( in = sy-sysid n = 2 ).
  ld_v__txt = sy-sysid.
  concatenate ld_v__txt ` -> ` ld_v__theme into ld_v__theme.
  message e022(zmx_bdch_badi) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.



  lv_buf = hor_tab( in = d_user_id n = 1 ).
  message e008(zmx_bdch_badi) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.

  call method convert_time
    exporting
      i_v__start      = gd_v__time_start
      i_v__end        = gd_v__time_end
    importing
      e_v__data_start = ld_v__start_date
      e_v__time_start = ld_v__start_time
      e_v__delta_time = ld_v__delta_time.


  concatenate ld_v__start_date `  ` ld_v__start_time into time.
  lv_buf =  hor_tab( in = time n = 1 ).
  message e009(zmx_bdch_badi) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.


  time = ld_v__delta_time.
  replace first occurrence of regex `\s+\<` in time with ``.
  message s010(zmx_bdch_badi) with time.
  lv_buf =  hor_tab( in = time n = 1 ).
  message e010(zmx_bdch_badi) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.

*--------------------------------------------------------------------*

  if if_succes = abap_false.
    message e016(zmx_bdch_badi) into ls_mailtxt.
    concatenate `ERROR! ` ld_v__theme into ld_v__theme.
  else.
    if if_warning = abap_true.
      message e019(zmx_bdch_badi) into ls_mailtxt.
      concatenate `WARNING! ` ld_v__theme into ld_v__theme.
    else.
      message e015(zmx_bdch_badi) into ls_mailtxt.
      concatenate `SUCCESS! ` ld_v__theme into ld_v__theme.
    endif.
  endif.

  message s011(zmx_bdch_badi) with ls_mailtxt.

  ls_mailtxt =  hor_tab( in = ls_mailtxt n = 2 ).

  message e011(zmx_bdch_badi) into ls_mailtxt with ls_mailtxt.
*  concatenate lv_hor_tab ls_mailtxt into ls_mailtxt.
  append ls_mailtxt to lt_mailtxt.

*--------------------------------------------------------------------*
  message e013(zmx_bdch_badi) into ls_mailtxt. " разделитель
  append ls_mailtxt to lt_mailtxt.


  message e018(zmx_bdch_badi) into ls_mailtxt. " выбор
  append ls_mailtxt to lt_mailtxt.


  split ds_badi_param-parameter at `;` into table lt_value.

  append
  : lines of lt_value to lt_mailtxt
  , initial line      to lt_mailtxt.

  message e014(zmx_bdch_badi) into ls_mailtxt. " выбор элементов
  append ls_mailtxt to lt_mailtxt.


  if not gv_f__rspc eq abap_true.

    lo_logger = cl_ujd_package_context=>get_logger( ).

    read table lo_logger->dt_log_content
         with key fieldname = 'PROMPT'
         into ls_message transporting value.

  else.
    ls_message-value = d_selection.
  endif.

  shift ls_message-value right deleting trailing '|'.

  find first occurrence of regex '@@@EXPAND@@@'
       in ls_message-value
       match offset lv_offset
       match length lv_lenght.

  add lv_lenght to lv_offset.

  split ls_message-value+lv_offset at '|DIMENSION:' into table lt_value.

  replace all occurrences of '|' in table lt_value with `: `.

  delete lt_value where table_line is initial.

  append lines of lt_value to lt_mailtxt.

  message e013(zmx_bdch_badi) into ls_mailtxt. " разделитель
  append ls_mailtxt to lt_mailtxt.
  lt_searchmailtxt = lt_mailtxt.
*--------------------------------------------------------------------*
  loop at gt_message  assigning <ld_s__message> where msgid is initial. " Сообщения
    append <ld_s__message>-message to lt_mailtxt.
  endloop.

  if not gv_f__rspc eq abap_true.

    read table lo_logger->dt_log_content
         with key fieldname = 'MESSAGE'
         into ls_message transporting value.

    split ls_message-value at cl_abap_char_utilities=>cr_lf
          into table lt_value.

    delete lt_value where table_line is initial.

    append lines of lt_value to lt_mailtxt.
  endif.

  if if_log = `1`.
    message e013(zmx_bdch_badi) into ls_mailtxt. " разделитель
    append ls_mailtxt to lt_mailtxt.

    lt_value = cl_ujk_logger=>get_log( ).
    append lines of lt_value to lt_mailtxt.
  endif.

* Recipients
  ls_mailrecipients-rec_type  = 'U'.
  ls_mailrecipients-receiver  = ld_v__mail.
  append ls_mailrecipients to lt_mailrecipients .

*  loop at ld_t__mail assigning <ld_v__mail>.
*    ls_mailrecipients-rec_type  = 'U'.
*    ls_mailrecipients-receiver = <ld_v__mail>.
*    append ls_mailrecipients to lt_mailrecipients .
*  endloop.

* Subject.
  ls_mailsubject-obj_langu = sy-langu.

  if not gv_f__rspc eq abap_true.
*    concatenate d_package_id ` (` sy-sysid `)`    into
*    : ls_mailsubject-obj_name
*    , ls_mailsubject-obj_descr
*    .

    ls_mailsubject-obj_name  = d_package_id.
    ls_mailsubject-obj_descr = d_package_id.
  else.
    ls_mailsubject-obj_name  = ld_v__theme.
    ls_mailsubject-obj_descr = ld_v__theme.
  endif.

  message s035(zbdnl).
*break-point .
* Send Mail
  if ( d_sendmail = 1 and ( if_succes = abap_false or if_warning = abap_true ) ) or
       d_sendmail = 2.
    call function 'SO_NEW_DOCUMENT_SEND_API1'
      exporting
        document_data              = ls_mailsubject
      tables
        object_content             = lt_mailtxt
        receivers                  = lt_mailrecipients
      exceptions
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        others                     = 8.

    if sy-subrc eq 0.
      commit work.
*   Push mail out from SAP outbox
      submit rsconn01 with mode = 'INT' and return.
    endif.
  endif.

  " Not optimal reading
  if ( zcl_bdnl_run_logic=>cd_t__searchmessage is not initial and ld_t__mail is not initial ) and
     gd_f__searchlog is initial.
    clear lt_mailrecipients.

    loop at ld_t__mail assigning <ld_v__mail>.
      ls_mailrecipients-rec_type  = 'U'.
      ls_mailrecipients-receiver = <ld_v__mail>.
      append ls_mailrecipients to lt_mailrecipients .
    endloop.

    clear lt_mailtxt.
    loop at zcl_bdnl_run_logic=>cd_t__searchmessage into ls_mailtxt.
      append ls_mailtxt to lt_searchmailtxt.
    endloop.

    call function 'SO_NEW_DOCUMENT_SEND_API1'
      exporting
        document_data              = ls_mailsubject
      tables
        object_content             = lt_searchmailtxt
        receivers                  = lt_mailrecipients
      exceptions
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        others                     = 8.

    if sy-subrc eq 0.
      commit work.
*   Push mail out from SAP outbox
      submit rsconn01 with mode = 'INT' and return.
    endif.
  endif.

endmethod.

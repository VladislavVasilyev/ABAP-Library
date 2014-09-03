method SEND_EMAIL.
  check i_send = abap_true.

  data " data declarations
      : ls_mailsubject     type sodocchgi1
      , lt_mailrecipients  type standard table of somlrec90
      , ls_mailrecipients  type somlrec90
      , lt_mailtxt         type standard table of soli
      , ls_mailtxt         type soli
      , time               type string
      , lo_logger          type ref to cl_ujd_logger
      , lv_buf             type string
      , lv_hor_tab         type string
      .

  field-symbols
      : <ls_mailtxt>       type soli
      .

**********************************************************************
* Заголовок письма
**********************************************************************
  lv_buf = hor_tab( in = ds_user-package_id n = 3 ).
  message e007(zmx_rb_logistics) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.

  lv_buf = hor_tab( in = ds_user-user_id n = 1 ).
  message e008(zmx_rb_logistics) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.


  time = get_log_time( start = ds_time_process-start end = ds_time_process-end mode = 2 ).
  lv_buf =  hor_tab( in = time n = 1 ).
  message e009(zmx_rb_logistics) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.

  time = get_log_time( start = ds_time_process-start end = ds_time_process-end mode = 3 ).
  lv_buf =  hor_tab( in = time n = 1 ).
  message e010(zmx_rb_logistics) into ls_mailtxt with lv_buf.
  append ls_mailtxt to lt_mailtxt.
*--------------------------------------------------------------------*

  if i_error = abap_true.
    message e016(zmx_rb_logistics) into ls_mailtxt.
  else.
    message e015(zmx_rb_logistics) into ls_mailtxt.
  endif.

  ls_mailtxt =  hor_tab( in = ls_mailtxt n = 2 ).

  message e011(zmx_rb_logistics) into ls_mailtxt with ls_mailtxt.

*  concatenate lv_hor_tab ls_mailtxt into ls_mailtxt.

  append ls_mailtxt to lt_mailtxt.

*--------------------------------------------------------------------*
  message e013(zmx_rb_logistics) into ls_mailtxt. " разделитель
  append ls_mailtxt to lt_mailtxt.

  message e014(zmx_rb_logistics) into ls_mailtxt. " выбор элементов
  append ls_mailtxt to lt_mailtxt.

  lo_logger = cl_ujd_package_context=>get_logger( ).

  data
      : ls_message type ujd_s_value
      , lt_value   type table of string
      , lv_lenght  type i
      , lv_offset  type i
      .

  read table lo_logger->dt_log_content
       with key fieldname = 'PROMPT'
       into ls_message transporting value.

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

  message e013(zmx_rb_logistics) into ls_mailtxt. " разделитель
  append ls_mailtxt to lt_mailtxt.
*--------------------------------------------------------------------*

  read table lo_logger->dt_log_content
       with key fieldname = 'MESSAGE'
       into ls_message transporting value.

  split ls_message-value at cl_abap_char_utilities=>cr_lf
        into table lt_value.

  delete lt_value where table_line is initial.

  append lines of lt_value to lt_mailtxt.


* Recipients
  ls_mailrecipients-rec_type  = 'U'.
  ls_mailrecipients-receiver  = ds_user-email.
  append ls_mailrecipients to lt_mailrecipients .
  clear ls_mailrecipients .

* Subject.
  ls_mailsubject-obj_name  = ds_user-package_id.
  ls_mailsubject-obj_langu = sy-langu.
  ls_mailsubject-obj_descr = ds_user-package_id.

* Send Mail
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

endmethod.

method print_log.

  data " data declarations
  : ls_mailsubject          type sodocchgi1
  , lt_mailrecipients       type standard table of somlrec90
  , ls_mailrecipients       type somlrec90
  , lt_mailtxt              type standard table of soli
  , ls_mailtxt              type soli
  , time                    type string
  , lo_logger               type ref to cl_ujd_logger
  , lv_buf                  type string
  , lv_hor_tab              type string
  , ld_v__mail              type uje_user-email
  , ld_t__mail              type table of string
  , ld_v__start_date        type string
  , ld_v__start_time        type string
  , ld_v__delta_time        type string
  , ld_v__str               type string
  , ld_v__value             type c length 20
  , ld_v__cnt               type i
  , ld_v__txt               type string
  , ld_v__theme             type string
  .

  data
  : ls_message              type ujd_s_value
  , lt_value                type table of string
  , lv_lenght               type i
  , lv_offset               type i
  .

  field-symbols
  : <ls_mailtxt>            type soli
  , <ld_s__value>           type string
  , <ld_s__message>         type uj0_s_message
  , <ld_v__mail>            type string
  .

*--------------------------------------------------------------------*
  split ds_badi_param-parameter at `;` into table lt_value.

  loop at lt_value into ls_mailtxt.
    if sy-tabix = 1.
      message s018(zmx_bdch_badi). " выбор
    endif.
    mprint> ls_mailtxt.
  endloop.

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

  loop at lt_value into ls_mailtxt.
    if sy-tabix = 1.
      message s014(zmx_bdch_badi). " выбор элементов
    endif.

    mprint> ls_mailtxt.
  endloop.

*--------------------------------------------------------------------*
endmethod.

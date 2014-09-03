method WRITE_LOG_PACK.

data lt_message type uj0_t_message.

*log_pl           type c      value '1'
*log_fl           type c      value '2'
*log_pf           type c      value '3'


*  if mode = cs-log_pl or mode = cs-log_pf.
*    call method cl_ujd_utility=>write_long_message
*      exporting
*        i_message  = message
*      changing
*        ct_message = lt_message.
*    cl_ujd_custom_type=>write_message_log( lt_message ).
**    append message to ds_mailtxt-package_log.
*  endif.
*
*  if mode = cs-log_fl or mode = cs-log_pf.
*    cl_ujk_logger=>log( message ).
**    append message to ds_mailtxt-formula_log.
*  endif.

endmethod.

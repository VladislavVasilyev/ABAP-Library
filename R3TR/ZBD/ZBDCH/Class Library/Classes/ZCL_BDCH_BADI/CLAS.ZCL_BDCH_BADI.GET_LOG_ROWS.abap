method GET_LOG_ROWS.
  data str type string.
  data submit type string.
  data success type string.
  data fail type string.
  data len type i.
  data i type i.
  data r type i value 10.

  submit  = is_rw_log-st_rec-nr_submit.
  success = is_rw_log-st_rec-nr_success.
  fail    = is_rw_log-st_rec-nr_fail.

  str = '@@@@@@@@@@@@@@@@@@@@'.

  concatenate
      : str submit  into submit
      , str success into success
      , str fail    into fail
      .

  condense
    : submit  no-gaps
    , success no-gaps
    , fail    no-gaps
    .

    i = strlen( submit ) - r.
    submit = submit+i(r).
    i = strlen( success ) - r.
    success = success+i(r).
    i = strlen( fail ) - r.
    fail = fail+i(r).

  case is_rw_log-type.
    when cs-log_read_full or
         cs-log_read_pack.
         res = '[S.@X1]'.
         replace 'X1' in res with submit.
    when cs-log_write_full or
         cs-log_write_pack.
         res = '[S.@X1][W.@X2][E.@X3]'.
         replace 'X1' in res with submit.
         replace 'X2' in res with success.
         replace 'X3' in res with fail.
  endcase.
endmethod.

method get_token.

  constants cs_name type string value `^([A-Z\_])([A-Z0-9\_]+)$`.

  data
  : ld_v__tabix     type i
  , ld_v__from      type i
  , ld_v__to        type i
  , ld_v__name      type string.
  .

  field-symbols
  : <ld_s__token_list> type zbnlt_s__match_res
  .

  if gd_v__index = 0.
    ld_v__from = 1.
  else.
    ld_v__from = gd_v__index.
  endif.

  if trn = 0.
    ld_v__to = ld_v__from.
  else.
    ld_v__to = ld_v__from + trn - 1.
  endif.

  if ld_v__from > lines( gd_t__tokenlist ).
    gd_f__end = abap_true.
    clear token.
    return.
  endif.

  loop at gd_t__tokenlist
       assigning <ld_s__token_list>
            from ld_v__from
              to ld_v__to
           where esc ne abap_true.

    ld_v__tabix = sy-tabix.
    if <ld_s__token_list>-f_variable = abap_true.
      token = <ld_s__token_list>-value.
    else.
      token = <ld_s__token_list>-token.
    endif.


    check esc = abap_true.
    <ld_s__token_list>-esc = abap_true.

  endloop.

  if sy-subrc ne 0.
    loop at gd_t__tokenlist
       from ld_v__from
       assigning <ld_s__token_list>
            where esc ne abap_true.
      gd_v__index = sy-tabix.
      exit.
    endloop.

    call method get_token
      exporting
        esc   = esc
        trn   = trn
        chn   = chn
      receiving
        token = token.
    return.
  endif.

  gd_v__index = gd_v__cindex = ld_v__tabix.
  gd_v__ctoken = token.

  if chn = abap_true.
    find first occurrence of regex cs_name in token ignoring case.

    if sy-subrc <> 0.
      raise exception type zcx_bdnl_syntax_error
             exporting textid = zcx_bdnl_syntax_error=>zcx_format_name
               token  = token
               index  = gd_v__index .

    endif.
  endif.

  check esc = abap_true.
  add 1 to gd_v__index.

endmethod.

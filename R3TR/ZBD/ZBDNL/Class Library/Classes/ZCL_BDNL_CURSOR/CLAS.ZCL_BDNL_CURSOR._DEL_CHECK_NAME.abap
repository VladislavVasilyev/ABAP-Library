method _DEL_CHECK_NAME.

  constants cs_name type string value `^([A-Z\_])([A-Z0-9\_]+)$`.

  data ld_v__name type string.


  ld_v__name = get_token( ).

  find first occurrence of regex cs_name in ld_v__name ignoring case.

  if sy-subrc <> 0.
    raise exception type zcx_bdnl_syntax_error
           exporting textid = zcx_bdnl_syntax_error=>zcx_format_name
             token  = ld_v__name
             index  = gd_v__index .

  endif.

endmethod.

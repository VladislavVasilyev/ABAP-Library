method check_directory.

  data
  : l_regex type string
  .

  l_regex = '\A([a-z]):\\([^/:*?"<>$ \r\n]*\\)$'.
  find first occurrence of regex l_regex in directory ignoring case.

  if sy-subrc = 0.
    check = abap_true.
  else.
    check = abap_false.
  endif.

endmethod.

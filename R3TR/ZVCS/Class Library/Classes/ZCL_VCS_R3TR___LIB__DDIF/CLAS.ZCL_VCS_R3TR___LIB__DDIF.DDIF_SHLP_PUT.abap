method ddif_shlp_put.

  call function 'DDIF_SHLP_PUT'
    exporting
      name              = name
      dd30v_wa          = dd30v_wa
    tables
      dd31v_tab         = dd31v_tab
      dd32p_tab         = dd32p_tab
      dd33v_tab         = dd33v_tab
    exceptions
      shlp_not_found    = 1
      name_inconsistent = 2
      shlp_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      others            = 6.

  mac__module_raise ddif_shlp_put
  : 1 shlp_not_found
  , 2 name_inconsistent
  , 3 shlp_inconsistent
  , 4 put_failure
  , 5 put_refused
  , 6 others
  .



endmethod.

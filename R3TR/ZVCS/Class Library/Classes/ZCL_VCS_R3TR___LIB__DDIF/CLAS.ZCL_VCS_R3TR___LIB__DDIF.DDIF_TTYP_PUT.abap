method ddif_ttyp_put.

  call function 'DDIF_TTYP_PUT'
    exporting
      name              = name
      dd40v_wa          = dd40v_wa
    tables
      dd42v_tab         = dd42v_tab
    exceptions
      ttyp_not_found    = 1
      name_inconsistent = 2
      ttyp_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      others            = 6.

  mac__module_raise ddif_ttyp_put
  : 1 ttyp_not_found
  , 2 name_inconsistent
  , 3 ttyp_inconsistent
  , 4 put_failure
  , 5 put_refused
  , 6 others
  .

endmethod.

method ddif_dtel_put.

  call function 'DDIF_DTEL_PUT'
    exporting
      name              = name
      dd04v_wa          = dd04v_wa
    exceptions
      dtel_not_found    = 1
      name_inconsistent = 2
      dtel_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      others            = 6.

  mac__module_raise ddif_dtel_put
  : 1 dtel_not_found
  , 2 name_inconsistent
  , 3 dtel_inconsistent
  , 4 put_failure
  , 5 put_refused
  , 6 others.

endmethod.

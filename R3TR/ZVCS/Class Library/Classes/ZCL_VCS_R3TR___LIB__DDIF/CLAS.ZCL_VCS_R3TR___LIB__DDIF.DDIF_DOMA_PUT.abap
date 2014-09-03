method ddif_doma_put.

  call function 'DDIF_DOMA_PUT'
    exporting
      name              = name
      dd01v_wa          = dd01v_wa
    tables
      dd07v_tab         = dd07v_tab
    exceptions
      doma_not_found    = 1
      name_inconsistent = 2
      doma_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      others            = 6.

  mac__module_raise  ddif_doma_put
  : 1 doma_not_found
  , 2 name_inconsistent
  , 3 doma_inconsistent
  , 4 put_failure
  , 5 put_refused
  , 6 others.

endmethod.

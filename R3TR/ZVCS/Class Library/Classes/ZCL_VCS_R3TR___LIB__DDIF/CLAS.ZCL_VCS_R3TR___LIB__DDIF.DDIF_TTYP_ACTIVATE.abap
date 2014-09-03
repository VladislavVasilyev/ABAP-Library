method ddif_ttyp_activate.

  call function 'DDIF_TTYP_ACTIVATE'
    exporting
      name        = name
      prid        = prid
    importing
      rc          = rc
    exceptions
      not_found   = 1
      put_failure = 2
      others      = 3.

  mac__module_raise ddif_ttyp_activate
  : 1 not_found
  , 2 put_failure
  , 3 others
  .

endmethod.

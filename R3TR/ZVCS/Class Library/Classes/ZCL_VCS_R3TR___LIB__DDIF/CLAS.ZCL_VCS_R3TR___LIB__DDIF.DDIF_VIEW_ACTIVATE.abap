method ddif_view_activate.

  call function 'DDIF_VIEW_ACTIVATE'
    exporting
      name        = name
      prid        = prid
      auth_chk    = auth_chk
    importing
      rc          = rc
    exceptions
      not_found   = 1
      put_failure = 2
      others      = 3.

  mac__module_raise ddif_view_activate
  : 1 not_found
  , 2 put_failure
  , 3 others
  .

endmethod.

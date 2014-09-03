method tr_devclass_get.

  call function 'TR_DEVCLASS_GET'
    exporting
      iv_devclass        = iv_devclass
      iv_langu           = iv_langu
    importing
      es_tdevc           = es_tdevc
    exceptions
      devclass_not_found = 1
      others             = 2.

  mac__module_raise tr_devclass_get
  : 1 devclass_not_found
  , 2 others
  .

endmethod.

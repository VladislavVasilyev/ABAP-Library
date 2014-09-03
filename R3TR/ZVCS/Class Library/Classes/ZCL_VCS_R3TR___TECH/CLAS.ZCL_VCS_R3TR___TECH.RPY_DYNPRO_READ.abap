method rpy_dynpro_read.

  call function 'RPY_DYNPRO_READ'
    exporting
      progname              = progname
      dynnr                 = dynnr
      suppress_exist_checks = suppress_exist_checks
      suppress_corr_checks  = suppress_corr_checks
    importing
      header                = header
    tables
      containers            = containers
      fields_to_containers  = fields_to_containers
      flow_logic            = flow_logic
      params                = params
    exceptions
      cancelled             = 1
      not_found             = 2
      permission_error      = 3
      others                = 4.

  mac__module_raise rpy_dynpro_read
  : 1 cancelled
  , 2 not_found
  , 3 permission_error
  , 4 others
  .

endmethod.

method rpy_dynpro_insert.

  call function 'RPY_DYNPRO_INSERT'
    exporting
      suppress_corr_checks     = suppress_corr_checks
      corrnum                  = corrnum
      suppress_exist_checks    = suppress_exist_checks
      suppress_generate        = suppress_generate
      suppress_dict_support    = suppress_dict_support
      suppress_extended_checks = suppress_extended_checks
      header                   = header
      use_corrnum_immediatedly = use_corrnum_immediatedly
      suppress_commit_work     = suppress_commit_work
    tables
      containers               = containers
      fields_to_containers     = fields_to_containers
      flow_logic               = flow_logic
      params                   = params
    exceptions
      cancelled                = 1
      already_exists           = 2
      program_not_exists       = 3
      not_executed             = 4
      missing_required_field   = 5
      illegal_field_value      = 6
      field_not_allowed        = 7
      not_generated            = 8
      illegal_field_position   = 9
      others                   = 10.


  mac__module_raise rpy_dynpro_insert
  : 1  cancelled
  , 2  already_exists
  , 3  program_not_exists
  , 4  not_executed
  , 5  missing_required_field
  , 6  illegal_field_value
  , 7  field_not_allowed
  , 8  not_generated
  , 9  illegal_field_position
  , 10 others
  .

endmethod.

method rpy_program_insert.

  call function 'RPY_PROGRAM_INSERT'
    exporting
      application         = application
      authorization_group = authorization_group
      development_class   = development_class
      edit_lock           = edit_lock
      log_db              = log_db
      program_name        = program_name
      program_type        = program_type
      r2_flag             = r2_flag
      temporary           = temporary
      title_string        = title_string
      transport_number    = transport_number
      save_inactive       = save_inactive
    tables
      source_extended     = source_extended
    exceptions
      already_exists      = 1
      cancelled           = 2
      name_not_allowed    = 3
      permission_error    = 4
      others              = 5.

  mac__module_raise rpy_program_insert
  : 1 already_exists
  , 2 cancelled
  , 3 name_not_allowed
  , 4 permission_error
  , 5 others
  .

endmethod.

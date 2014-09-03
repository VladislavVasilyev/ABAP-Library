method rpy_program_read.

  call function 'RPY_PROGRAM_READ'
    exporting
      language            = sy-langu
      program_name        = program_name
      with_includelist    = with_includelist
      only_source         = only_source
      only_texts          = only_texts
      read_latest_version = read_latest_version
      with_lowercase      = with_lowercase
    importing
      prog_inf            = prog_inf
    tables
      include_tab         = include_tab
      source              = source
      source_extended     = source_extended
      textelements        = textelements
    exceptions
      cancelled           = 1
      not_found           = 2
      permission_error    = 3
      others              = 4.

  mac__module_raise rpy_program_read
  : 1 cancelled
  , 2 not_found
  , 3 permission_error
  , 4 others
  .

endmethod.

method rs_get_all_includes.

  call function 'RS_GET_ALL_INCLUDES'
    exporting
      program                = program
      with_inactive_incls    = with_inactive_incls
      with_reserved_includes = with_reserved_includes
    tables
      includetab             = includetab
    exceptions
      not_existent           = 1
      no_program             = 2
      others                 = 3.

  mac__module_raise RS_GET_ALL_INCLUDES
  : 1 not_existing
  , 2 no_program
  .


endmethod.

method rs_progname_split.

  call function 'RS_PROGNAME_SPLIT'
    exporting
      progname_with_namespace     = progname_with_namespace
    importing
      namespace                   = namespace
      progname_without_namespace  = progname_without_namespace
      fugr_is_name                = fugr_is_name
      fugr_is_reserved_name       = fugr_is_reserved_name
      fugr_is_functionpool_name   = fugr_is_functionpool_name
      fugr_is_include_name        = fugr_is_include_name
      fugr_is_functionmodule_name = fugr_is_functionmodule_name
      fugr_is_hidden_name         = fugr_is_hidden_name
      fugr_group                  = fugr_group
      fugr_include_number         = fugr_include_number
      fugr_suffix                 = fugr_suffix
      fugr_is_reserved_exit_name  = fugr_is_reserved_exit_name
      sldb_is_reserved_name       = sldb_is_reserved_name
      sldb_logdb_name             = sldb_logdb_name
      mst_is_reserved_name        = mst_is_reserved_name
      type_is_reserved_name       = type_is_reserved_name
      type_name                   = type_name
      menu_is_reserved_name       = menu_is_reserved_name
      menu_name                   = menu_name
      class_is_reserved_name      = class_is_reserved_name
      class_is_name               = class_is_name
      class_name                  = class_name
      class_is_method_name        = class_is_method_name
      class_method_name           = class_method_name
      cntx_is_reserved_name       = cntx_is_reserved_name
    exceptions
      delimiter_error             = 1
      others                      = 2.


  mac__module_raise rs_progname_split
 : 1 delimeter_error
 , 2 others
 .

endmethod.

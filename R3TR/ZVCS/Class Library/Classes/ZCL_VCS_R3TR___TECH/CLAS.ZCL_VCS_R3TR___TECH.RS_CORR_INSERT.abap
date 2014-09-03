method rs_corr_insert.

  call function 'RS_CORR_INSERT'
    exporting
      object                   = object
      object_class             = object_class
      mode                     = mode
      global_lock              = global_lock
      devclass                 = devclass
      korrnum                  = korrnum
      use_korrnum_immediatedly = use_korrnum_immediatedly
      author                   = author
      master_language          = master_language
      genflag                  = genflag
      program                  = program
      object_class_supports_ma = object_class_supports_ma
      extend                   = extend
      suppress_dialog          = suppress_dialog
      mod_langu                = mod_langu
      activation_call          = activation_call
    importing
      devclass                 = edevclass
      korrnum                  = ekorrnum
      ordernum                 = ordernum
      new_corr_entry           = new_corr_entry
      author                   = eauthor
      transport_key            = transport_key
      new_extend               = new_extend
    exceptions
      cancelled                = 1
      permission_failure       = 2
      unknown_objectclass      = 3
      others                   = 4.

  mac__module_raise rs_corr_insert
  : 1  cancelled
  , 2  permission_failure
  , 3  unknown_objectclass
  , 4  others
  .

endmethod.

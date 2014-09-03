method READ_METHOD_PARAMS.
*
  data
  : cmpkey type seocmpkey.

* refresh
  free parameters.

*
  cmpkey-clsname = method-clsname.
  cmpkey-cmpname = method-cmpname.
*
  call method zcl_vcs_r3tr___tech=>parameter_read_all
    exporting
      cmpkey            = cmpkey
      version           = seoc_version_active
      master_language   = sy-langu
      modif_language    = sy-langu
      with_descriptions = seox_true
    importing
      parameters        = parameters[].

endmethod.

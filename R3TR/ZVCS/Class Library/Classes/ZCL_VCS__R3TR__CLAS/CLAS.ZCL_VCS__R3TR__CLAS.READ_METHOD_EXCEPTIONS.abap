method READ_METHOD_EXCEPTIONS.

* refresh
  free method_exceptions.

  call method zcl_vcs_r3tr___lib__seo=>seo_exception_read_all
    exporting
      cmpkey                       = method-cmpkey
*       VERSION                      = SEOC_VERSION_INACTIVE
*       MASTER_LANGUAGE              = SY-LANGU
*       MULTISOFT                    = SY-LANGU
*       WITH_DESCRIPTIONS            = SEOX_TRUE
    importing
      exceps                       = method_exceptions.

endmethod.

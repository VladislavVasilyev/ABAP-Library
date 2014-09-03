method SEO_CLASS_GET_METHOD_INCLUDES.

  call function 'SEO_CLASS_GET_METHOD_INCLUDES'
    exporting
      clskey                       = clskey
    importing
      includes                     = includes
    exceptions
      _internal_class_not_existing = 1
      others                       = 2.

  mac__module_raise seo_class_get_method_includes
  : 1 class_not_existing
  , 2 others.

endmethod.

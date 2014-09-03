method SEO_METHOD_GET.

  call function 'SEO_METHOD_GET'
    exporting
      mtdkey       = mtdkey
      version      = version
    importing
      method       = method
    exceptions
      not_existing = 1
      deleted      = 2
      is_event     = 3
      is_type      = 4
      is_attribute = 5
      others       = 6.

  mac__module_raise seo_method_get
  : 1 not_existing
  , 2 deleted
  , 3 is_event
  , 4 is_type
  , 5 is_attribute
  , 6 others
  .

endmethod.

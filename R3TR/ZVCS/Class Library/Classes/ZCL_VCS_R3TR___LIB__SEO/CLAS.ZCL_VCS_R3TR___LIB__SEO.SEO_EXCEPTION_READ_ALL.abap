method SEO_EXCEPTION_READ_ALL.

  call function 'SEO_EXCEPTION_READ_ALL'
    exporting
      cmpkey                 = cmpkey
      version                = version
      master_language        = master_language
      modif_language         = modif_language
      with_descriptions      = with_descriptions
    importing
      exceps                 = exceps
    exceptions
      component_not_existing = 1
      others                 = 2.

  mac__module_raise seo_exception_read_all
  : 1 comp_not_existing
  , 2 others
  .

endmethod.

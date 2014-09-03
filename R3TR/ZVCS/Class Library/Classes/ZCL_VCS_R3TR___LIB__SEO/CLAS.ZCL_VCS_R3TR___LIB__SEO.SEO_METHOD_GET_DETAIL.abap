method SEO_METHOD_GET_DETAIL.

  call function 'SEO_METHOD_GET_DETAIL'
    exporting
      cpdkey         = cpdkey
    importing
      method         = method
      method_details = method_details
    exceptions
      not_existing   = 1
      no_method      = 2
      others         = 3.

  mac__module_raise seo_method_get_detail
  : 1 not_existing
  , 2 no_method
  , 3 others
  .


endmethod.

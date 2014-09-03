method seo_class_existence_check.

  call function 'SEO_CLASS_EXISTENCE_CHECK'
    exporting
      clskey        = clskey
    importing
      not_active    = not_active
    exceptions
      not_specified = 1
      not_existing  = 2
      is_interface  = 3
      no_text       = 4
      inconsistent  = 5
      others        = 6.

  mac__module_raise seo_class_existence_check
  : 1 not_specified
  , 2 not_existing
  , 3 is_interface
  , 4 no_text
  , 5 inconsistent
  , 6 others
  .

endmethod.

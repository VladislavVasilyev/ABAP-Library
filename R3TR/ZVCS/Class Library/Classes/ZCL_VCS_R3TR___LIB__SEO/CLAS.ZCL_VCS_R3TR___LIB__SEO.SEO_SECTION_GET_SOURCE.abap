method SEO_SECTION_GET_SOURCE.

  if state is supplied.

    call function 'SEO_SECTION_GET_SOURCE'
      exporting
        cifkey               = cifkey
        limu                 = limu
        state                = state
      importing
        source               = source
        incname              = incname
      exceptions
        class_not_existing   = 1
        version_not_existing = 2
        others               = 3.

  else.
    call function 'SEO_SECTION_GET_SOURCE'
      exporting
        cifkey               = cifkey
        limu                 = limu
*      state                = state
      importing
        source               = source
        incname              = incname
      exceptions
        class_not_existing   = 1
        version_not_existing = 2
        others               = 3.
  endif.

  mac__module_raise seo_section_get_source
  : 1 class_not_existing
  , 2 version_not_existing
  , 3 others
  .

endmethod.

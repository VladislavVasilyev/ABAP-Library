method SEO_INTERFACE_TYPEINFO_GET.

  call function 'SEO_INTERFACE_TYPEINFO_GET'
    exporting
      intkey                  = intkey
      version                 = version
      state                   = state
      with_master_language    = with_master_language
      with_enhancements       = with_enhancements
      read_active_enha        = read_active_enha
      enha_action             = enha_action
      ignore_switches         = ignore_switches
    importing
      interface               = interface
      attributes              = attributes
      methods                 = methods
      events                  = events
      parameters              = parameters
      exceps                  = exceps
      comprisings             = comprisings
      typepusages             = typepusages
      clsdeferrds             = clsdeferrds
      intdeferrds             = intdeferrds
      explore_comprisings     = explore_comprisings
      aliases                 = aliases
      types                   = types
      enhancement_methods     = enhancement_methods
      enhancement_attributes  = enhancement_attributes
      enhancement_events      = enhancement_events
      enhancement_comprisings = enhancement_comprisings
    exceptions
      not_existing            = 1
      is_class                = 2
      model_only              = 3
      others                  = 4.

  mac__module_raise seo_interface_typeinfo_get
  : 1 not_existing
  , 2 is_class
  , 3 model_only
  , 4 others
  .


endmethod.

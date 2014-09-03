method seo_interface_create_complete.

  call function 'SEO_INTERFACE_CREATE_COMPLETE'
    exporting
      corrnr                       = corrnr
      devclass                     = devclass
      version                      = version
      genflag                      = genflag
      authority_check              = authority_check
      overwrite                    = overwrite
      suppress_refactoring_support = suppress_refactoring_support
    importing
      korrnr                       = korrnr
    tables
      class_descriptions           = class_descriptions
      component_descriptions       = component_descriptions
      subcomponent_descriptions    = subcomponent_descriptions
    changing
      interface                    = interface
      comprisings                  = comprisings
      attributes                   = attributes
      methods                      = methods
      events                       = events
      parameters                   = parameters
      exceps                       = exceps
      aliases                      = aliases
      typepusages                  = typepusages
      clsdeferrds                  = clsdeferrds
      intdeferrds                  = intdeferrds
      types                        = types
    exceptions
      existing                     = 1
      is_class                     = 2
      db_error                     = 3
      component_error              = 4
      no_access                    = 5
      other                        = 6
      others                       = 7.

  mac__module_raise seo_interface_create_complete
  : 1 existing
  , 2 is_class
  , 3 db_error
  , 4 component_error
  , 5 no_access
  , 6 other
  , 7 others
  .

endmethod.

method SEO_CLASS_TYPEINFO_GET.

  call function 'SEO_CLASS_TYPEINFO_GET'
    exporting
      clskey                        = clskey
      version                       = version
      state                         = state
      with_descriptions             = with_descriptions
      resolve_eventhandler_typeinfo = resolve_eventhandler_typeinfo
      with_master_language          = with_master_language
      with_enhancements             = with_enhancements
      read_active_enha              = read_active_enha
      enha_action                   = enha_action
      ignore_switches               = ignore_switches
    importing
      class                         = class
      attributes                    = attributes
      methods                       = methods
      events                        = events
      types                         = types
      parameters                    = parameters
      exceps                        = exceps
      implementings                 = implementings
      inheritance                   = inheritance
      redefinitions                 = redefinitions
      impl_details                  = impl_details
      friendships                   = friendships
      typepusages                   = typepusages
      clsdeferrds                   = clsdeferrds
      intdeferrds                   = intdeferrds
      explore_inheritance           = explore_inheritance
      explore_implementings         = explore_implementings
      aliases                       = aliases
      enhancement_methods           = enhancement_methods
      enhancement_attributes        = enhancement_attributes
      enhancement_events            = enhancement_events
      enhancement_implementings     = enhancement_implementings
    exceptions
      not_existing                  = 1
      is_interface                  = 2
      model_only                    = 3
      others                        = 4.

  mac__module_raise seo_class_typeinfo_get
  : 1 class_not_existing
  , 2 is_interface
  , 3 model_only
  , 4 others.

endmethod.

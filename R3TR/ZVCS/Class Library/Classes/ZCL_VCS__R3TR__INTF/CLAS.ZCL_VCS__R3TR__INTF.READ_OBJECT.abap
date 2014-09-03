method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__intf              type ty_s__intf
  .


  move
  : i_s__tadir-obj_name to ld_s__intf-intkey-clsname
  .

  try.
      call method zcl_vcs_r3tr___lib__seo=>seo_interface_typeinfo_get
       exporting
         intkey              = ld_s__intf-intkey
         version             = seoc_version_inactive
         state               = '1'
       importing
         interface           = ld_s__intf-interface
         attributes          = ld_s__intf-attributes
         methods             = ld_s__intf-methods
         events              = ld_s__intf-events
         parameters          = ld_s__intf-parameters
         exceps              = ld_s__intf-exceps
         comprisings         = ld_s__intf-comprisings
         typepusages         = ld_s__intf-typepusages
         clsdeferrds         = ld_s__intf-clsdeferrds
         intdeferrds         = ld_s__intf-intdeferrds
         types               = ld_s__intf-types
*        EXPLORE_COMPRISINGS = inter-explore_comprisings
         aliases             = ld_s__intf-aliases.
    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

  e_s__source = ld_s__intf.

endmethod.

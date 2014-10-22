method create_object.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  .


  data: clskey type seoclskey.



  field-symbols
  : <ld_s__upload>        type ty_s__upload
  , <ld_s__intf>          type ty_s__intf
  .

*  <ld_s__dtel> = i_r__source.

  loop at gd_t__upload assigning <ld_s__upload>.
    assign <ld_s__upload>-source->* to <ld_s__intf>.

    move <ld_s__intf>-intkey-clsname to clskey-clsname.

*--------------------------------------------------------------------*
* CHECK EXISTS
*--------------------------------------------------------------------*
    try.
        call method zcl_vcs_r3tr___lib__seo=>seo_class_existence_check
          exporting
            clskey = clskey.

      catch zcx_vcs__call_module_error .
*      raise exception type zcx_vcs_r3tr_objects_create
*            exporting textid = zcx_vcs_r3tr_objects_create=>cx_already_exists
*                      obj_name = I_S__TADIR-obj_name
*                      obj_type = I_S__TADIR-object.
    endtry.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
    try.
        call method zcl_vcs_r3tr___lib__seo=>seo_interface_create_complete
          exporting
*          corrnr                       =
            devclass                     = i_s__tadir-devclass
                        version                      = seoc_version_active "SEOC_VERSION_INACTIVE
                        genflag                      = i_s__tadir-genflag
*                      authority_check              = SEOX_TRUE
*                      overwrite                    = SEOX_FALSE
*                      suppress_refactoring_support = SEOX_TRUE
*          class_descriptions           =
*          component_descriptions       =
*          subcomponent_descriptions    =
*                    importing
*                      korrnr                       =
          changing
            interface                    = <ld_s__intf>-interface
            comprisings                  = <ld_s__intf>-comprisings
            attributes                   = <ld_s__intf>-attributes
            methods                      = <ld_s__intf>-methods
            events                       = <ld_s__intf>-events
            parameters                   = <ld_s__intf>-parameters
            exceps                       = <ld_s__intf>-exceps
            aliases                      = <ld_s__intf>-aliases
            typepusages                  = <ld_s__intf>-typepusages
            clsdeferrds                  = <ld_s__intf>-clsdeferrds
            intdeferrds                  = <ld_s__intf>-intdeferrds
            types                        = <ld_s__intf>-types.

      catch zcx_vcs__call_module_error into lr_x__call_module_error.
*      raise exception type zcx_vcs_objects_create__r3tr
*           exporting obj_name = i_s__tadir-obj_name
*                     object = i_s__tadir-object
*                     previous = lr_x__call_module_error.
    endtry.

  endloop.

endmethod.

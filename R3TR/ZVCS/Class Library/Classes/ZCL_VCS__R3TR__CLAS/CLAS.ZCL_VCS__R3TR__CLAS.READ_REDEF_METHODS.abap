method READ_REDEF_METHODS.

  data: includes type seop_methods_w_include,
        w_include like line of includes.
  data: w_redefinition type seoredef.
  data: method_redef type ty_s__redefinition.
  data: mtdkey type  seocpdkey,
        mtdkey1 type seocmpkey.
  data: explore type line of ty_s__ooclass-explore_inheritance.

  call method zcl_vcs_r3tr___lib__seo=>seo_class_get_method_includes
    exporting
      clskey   = i_s__clskey
    importing
      includes = includes.

  loop at includes into w_include.

* refresh
    free method_redef.

    read table i_t__methods
         transporting no fields
         with key method-cmpname = w_include-cpdkey-cpdname.

    if sy-subrc ne 0.

* Includename
      move w_include to method_redef-include.

* Method
      if w_include-cpdkey-cpdname ca '~'.
        continue.
      endif.

      clear w_redefinition.
      read table i_t__redefinitions
           into w_redefinition
      with key mtdname = w_include-cpdkey-cpdname.

      if sy-subrc eq 0.

        loop at i_t__explore_inheritance into explore.

* refresh
          free: method_redef-method, mtdkey1.

          move explore-clsname to mtdkey1-clsname.
          move w_redefinition-mtdname to mtdkey1-cmpname.

* Methodenattribute lesen
          try.
              call method zcl_vcs_r3tr___lib__seo=>seo_method_get
                exporting
                  mtdkey  = mtdkey1
                  version = seoc_version_inactive
                importing
                  method  = method_redef-method.
            catch zcx_vcs__call_module_error.
              exit.
          endtry.

        endloop.

* Source
        free: mtdkey, method_redef-source.
        mtdkey-clsname = w_include-cpdkey-clsname.
        mtdkey-cpdname = w_include-cpdkey-cpdname.

        call method zcl_vcs_r3tr___lib__seo=>seo_method_get_source
          exporting
            mtdkey                      = mtdkey
            state                       = 'A'
          importing
            source                      = method_redef-source
*               SOURCE_EXPANDED             =
            incname                     = w_include-incname.

        append method_redef to e_t__methods_redef.
      endif.

    endif.

* refresh
    free method_redef.

  endloop.

endmethod.

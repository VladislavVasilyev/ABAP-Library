method READ_TYPE_SOURCE.

  data
  : ld_v__typkey        type seocmpkey
  , ld_v__type          type line of ty_s__ooclass-types-types
  , ld_t__source        type zvcst_t__char255 "seop_source.
  , ld_x__module_error  type ref to zcx_vcs__call_module_error
  .

  loop at i_t__types into ld_v__type .

    refresh ld_t__source.
    move-corresponding ld_v__type to ld_v__typkey .

    try.
        call method zcl_vcs_r3tr___lib__seo=>seo_class_get_type_source
          exporting
            typkey = ld_v__typkey
          importing
            source = ld_t__source.

        append lines of ld_t__source to e_t__source.
      catch zcx_vcs__call_module_error into ld_x__module_error.
        check ld_x__module_error->exception <> zcx_vcs__call_module_error=>exc-not_edited.

        raise exception type zcx_vcs__call_module_error
              exporting exception    = ld_x__module_error->exception
                        module = ld_x__module_error->module.
    endtry.
  endloop.

endmethod.

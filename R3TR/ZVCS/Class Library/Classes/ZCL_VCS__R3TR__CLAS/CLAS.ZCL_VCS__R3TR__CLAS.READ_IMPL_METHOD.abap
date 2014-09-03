method READ_IMPL_METHOD.

  data
  : includes              type seop_methods_w_include
  , w_include             like line of includes
  , method_impl           type line of ty_s__ooclass-methods_impl
  , mtdkey                type  seocpdkey
  , mtdkey1               type seocmpkey
  , w_alias               like method_impl-alias
  .

* Includes lesen
  call method zcl_vcs_r3tr___lib__seo=>seo_class_get_method_includes
    exporting
      clskey   = i_s__clskey
    importing
      includes = includes.


  loop at includes into w_include.
* refresh
    free: method_impl, mtdkey, mtdkey1.

    read table i_t__methods
      transporting no fields
      with key method-cmpname = w_include-cpdkey-cpdname.

    if sy-subrc ne 0.

* Includename
      move w_include to method_impl-include.

* Method
      if w_include-cpdkey-cpdname ca '~'.
* Iterface
        split w_include-cpdkey-cpdname at '~'
        into mtdkey1-clsname mtdkey1-cmpname.
      else.
* Redefinition
        continue.
      endif.

      try.
          call method zcl_vcs_r3tr___lib__seo=>seo_method_get
            exporting
              mtdkey  = mtdkey1
              version = seoc_version_inactive
            importing
              method  = method_impl-method.
        catch zcx_vcs__call_module_error.
          continue.
      endtry.


* Source
      mtdkey-clsname = w_include-cpdkey-clsname.
      mtdkey-cpdname = w_include-cpdkey-cpdname.

      call method zcl_vcs_r3tr___lib__seo=>seo_method_get_source
        exporting
          mtdkey                      = mtdkey
          state                       = 'A'
        importing
          source                      = method_impl-source
*             SOURCE_EXPANDED             =
          incname                     = w_include-incname.

* Alias
      clear w_alias.
      read table i_t__aliases into w_alias
         with key
         refclsname = mtdkey1-clsname
         refcmpname = mtdkey1-cmpname.
      if sy-subrc eq 0.
        move w_alias to method_impl-alias.
      else.
        clear method_impl-alias.
      endif.
      append method_impl to e_t__impl_methods.

    endif.

    free method_impl.

*  endif.
  endloop.
endmethod.

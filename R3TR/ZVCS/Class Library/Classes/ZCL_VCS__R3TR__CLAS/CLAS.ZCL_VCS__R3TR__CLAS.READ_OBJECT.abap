method READ_OBJECT.

  data
  : ld_t__explore             type seok_cls_typeinfos
  , ld_t__methods             type seoo_methods_r
  , ld_s__clskey              type seoclskey
  , ld_s__vseoclass           type vseoclass
  , lr_x__call_module_error   type ref to zcx_vcs__call_module_error
  , ld_s__ooclass             type ty_s__ooclass
  .

  field-symbols
  : <ld_s__explore>           type line of seok_cls_typeinfos
  .


  move i_s__tadir-obj_name  to ld_s__clskey-clsname.

  try.
      call method zcl_vcs_r3tr___lib__seo=>seo_class_typeinfo_get
       exporting
         clskey                             = ld_s__clskey
         version                            = seoc_version_inactive
         state                              = '1'
         with_descriptions                  = seox_true
         resolve_eventhandler_typeinfo      = seox_false
      importing
        class                               = ld_s__vseoclass
        attributes                          = ld_s__ooclass-attributes
        methods                             = ld_t__methods
        events                              = ld_s__ooclass-events
        types                               = ld_s__ooclass-types-types
*     PARAMETERS                          =
*     EXCEPS                              =
     implementings                          = ld_s__ooclass-implementings-implementings
        inheritance                         = ld_s__ooclass-inheritance
        redefinitions                       = ld_s__ooclass-redefinitions
      impl_details                          = ld_s__ooclass-implementings-impl_details
        friendships                         = ld_s__ooclass-friends
        typepusages                         = ld_s__ooclass-typepusages
        clsdeferrds                         = ld_s__ooclass-classdeferreds
        intdeferrds                         = ld_s__ooclass-interfacedeferreds
        explore_inheritance                 = ld_t__explore
*     EXPLORE_IMPLEMENTINGS               =
        aliases                             = ld_s__ooclass-aliases.

      move-corresponding
      : ld_s__vseoclass to ld_s__ooclass-vseoclass
      .

      " Explore
      loop at ld_t__explore assigning <ld_s__explore>.
        append <ld_s__explore>-class to ld_s__ooclass-explore_inheritance.
      endloop.

      " Type Source
      call method read_type_source
        exporting
          i_t__types  = ld_s__ooclass-types-types
        importing
          e_t__source = ld_s__ooclass-types-type_source.

      " Section (Private Public Protected)
      call method read_sections
        exporting
          i_s__clskey  = ld_s__clskey
        importing
          e_t__section = ld_s__ooclass-sections.

      field-symbols
      : <ld_s__section> type ty_s__section
      .

      " Methoden lesen
      call method read_methods
        exporting
          i_t__methods = ld_t__methods
        importing
          e_t__methods = ld_s__ooclass-methods.

      " Locals
      call method read_locals
        exporting
          i_s__clskey = ld_s__clskey
        importing
          e_t__locals = ld_s__ooclass-locals.

      " implementierte(Interfaces) Methoden lesen
      call method read_impl_method
        exporting
          i_s__clskey       = ld_s__clskey
          i_t__methods      = ld_s__ooclass-methods
          i_t__aliases      = ld_s__ooclass-aliases
        importing
          e_t__impl_methods = ld_s__ooclass-methods_impl.

      call method read_redef_methods
        exporting
          i_s__clskey              = ld_s__clskey
          i_t__methods             = ld_s__ooclass-methods
          i_t__redefinitions       = ld_s__ooclass-redefinitions
          i_t__explore_inheritance = ld_s__ooclass-explore_inheritance
        importing
          e_t__methods_redef       = ld_s__ooclass-methods_redef.

**********************************************************************
* Save TXT
**********************************************************************
      data ld_s__txtsource type zvcst_s__source_path.

      ld_s__txtsource-pathnode = `/METHODS/item/SOURCE`.
      ld_s__txtsource-pathname = `/METHODS/item/CMPKEY/CMPNAME`.
      append  ld_s__txtsource to e_t__txtsource.

      ld_s__txtsource-pathnode = `/SECTIONS/item/SOURCE`.
      ld_s__txtsource-pathname = `/SECTIONS/item/LIMU`.
      append  ld_s__txtsource to e_t__txtsource.

      ld_s__txtsource-pathnode = `/METHODS_REDEF/item/SOURCE`.
      ld_s__txtsource-pathname = `/METHODS_REDEF/item/METHOD/CMPNAME`.
      append  ld_s__txtsource to e_t__txtsource.

      ld_s__txtsource-pathnode = `/METHODS_IMPL/item/SOURCE`.
      ld_s__txtsource-pathname = `/METHODS_IMPL/item/INCLUDE/CPDKEY/CPDNAME`.
      append  ld_s__txtsource to e_t__txtsource.

      ld_s__txtsource-pathnode = `/LOCALS/item/SOURCE`.
      ld_s__txtsource-pathname = `/LOCALS/item/NAME`.
      append  ld_s__txtsource to e_t__txtsource.

**********************************************************************


    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.


  e_s__source = ld_s__ooclass.



endmethod.

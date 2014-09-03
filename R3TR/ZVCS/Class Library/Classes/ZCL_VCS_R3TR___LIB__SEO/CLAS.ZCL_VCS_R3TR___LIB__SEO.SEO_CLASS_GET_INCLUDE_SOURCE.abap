method seo_class_get_include_source.

  data ld_t__source type seop_source_string.

  call function 'SEO_CLASS_GET_INCLUDE_SOURCE'
    exporting
      clskey                       = clskey
      inctype                      = inctype
    importing
      source_expanded              = ld_t__source
    exceptions
      _internal_class_not_existing = 1
      not_existing                 = 2
      others                       = 3.

  mac__module_raise seo_class_get_include_source
  : 1  _internal_class_not_existing
  , 2  not_existing
  , 3  others
  .

  source[] = ld_t__source.

* data
*  : text        type string
*  , filename    type progstruc
*  , _inctype(5).
*
*  _inctype = inctype.
*  system-call query class clskey-clsname.
*  if sy-subrc <> 0.
*    message s045(OO) with zvcsc_r3tr_type-clas  clskey-clsname into text.
*    mac__raise_message seo_class_get_include_source text.
*  endif.
*
*    clear filename.
*    filename-rootname = clskey-clsname.
*    translate filename-rootname using ' ='.
*
*  if inctype = seop_ext_class_locals_def or
*     inctype = seop_ext_class_locals_imp or
*     inctype = seop_ext_class_macros or
*     inctype = seop_ext_class_testclasses.
*    filename-categorya = inctype(1).
*    filename-codea = inctype+1(4).
*  else.
*    filename-categorya = inctype(1).
*    filename-codea = inctype+1(1).
*  endif.
*
*  read report filename into source_expanded.
*  if sy-subrc <> 0.
*    message s003(OO) with text-inc filename into text.
*    mac__raise_message seo_class_get_include_source text.
*  endif.
*
*  source = source_expanded.

endmethod.

method READ_METHOD_SOURCE.

  data
  : begin of seo_method_get_source
    , mtdkey      type seocpdkey
    , source      type zvcst_t__char255
    , incname     type program
    , end of seo_method_get_source
  , orgsource like seo_method_get_source-source
  , ld_t__source type seop_source_string.
  .

*  refresh
  free: source, incname.

*
  seo_method_get_source-mtdkey-clsname = method-clsname.
  seo_method_get_source-mtdkey-cpdname = method-cmpname.

  call method zcl_vcs_r3tr___lib__seo=>seo_method_get_source
    exporting
      mtdkey  = seo_method_get_source-mtdkey
      state   = 'A'
    importing
      source  = source[]
      incname = seo_method_get_source-incname.

  incname = seo_method_get_source-incname.
  orgsource[] = seo_method_get_source-source.
  call method zcl_vcs_r3tr___tech=>pretty_printer
    exporting
      inctoo                        = space
*   IMPORTING
*     INDENTATION_MAYBE_WRONG       =
    changing
      ntext                         = orgsource[]
      otext                         = seo_method_get_source-source[].

endmethod.

method seo_method_get_source.

  data ld_t__source type seop_source_string.

  call function 'SEO_METHOD_GET_SOURCE'
    exporting
      mtdkey                        = mtdkey
      state                         = state
    importing
      source_expanded               = ld_t__source
      incname                       = incname
    exceptions
      _internal_method_not_existing = 1
      _internal_class_not_existing  = 2
      version_not_existing          = 3
      inactive_new                  = 4
      inactive_deleted              = 5
      others                        = 6.

  mac__module_raise seo_method_get_source
  : 1 _internal_method_not_existing
  , 2 _internal_class_not_existing
  , 3 version_not_existing
  , 4 inactive_new
  , 5 inactive_deleted
  , 6 others
  .

  source[] = ld_t__source[].


*  data
*  : filename    type progstruc
*  , new         type seox_boolean
*  , source_line type seop_source_line_string
*  , progname    type progname.
*
** check if internal class entry exists
*  system-call query class mtdkey-clsname.
*  if sy-subrc <> 0.
*    mac__module_raise seo_method_get_source  sy-subrc class_not_existing.
*  endif.
** get implementation include name
*  call method cl_oo_classname_service=>get_method_include
*    exporting
*      mtdkey = mtdkey
*    receiving
*      result = filename
*    exceptions
*      others = 1.
*  if sy-subrc = 1.
** ec Mai 2005: is it an enhancement method?
*    data enha_tool type ref to cl_enh_tool_class.
*    enha_tool = cl_enh_tool_class=>get_instance_by_method_key( mtdkey = mtdkey ).
*    if enha_tool is initial.
*      mac__module_raise seo_method_get_source sy-subrc method_not_existing.
*    else.
*      enha_tool->provide_newmeth_inclname(
*             exporting
*               cpdname          = mtdkey-cpdname
*             importing
*               includename      = progname
*             exceptions
*               no_include_found = 1
*               others           = 2  ).
*      if sy-subrc <> 0.
*        mac__module_raise seo_method_get_source sy-subrc method_not_existing.
*      else.
*        filename-rootname = progname(30).
*        filename-categorya = progname+30(1).
*        filename-codea = progname+31(4).
*      endif.
*    endif.
*  endif.
*
*  incname = filename.
*  if state is supplied.
*    if state = 'I'.
*      read report filename into source_expanded state 'I'.
*      if sy-subrc <> 0.
*        mac__module_raise seo_method_get_source sy-subrc version_not_existing.
*      endif.
*      read table source_expanded into source_line index 1.
*      if sy-subrc = 0.
*        if source_line = seop_src_inactive_deleted.
*          mac__module_raise seo_method_get_source sy-subrc inactive_delete.
*        endif.
*      endif.
*    elseif state = 'A'.
*      read report filename into source_expanded state 'A'.
*      if sy-subrc <> 0.
*        mac__module_raise seo_method_get_source sy-subrc version_not_existing.
*      endif.
*      read table source_expanded into source_line index 1.
*      if sy-subrc = 0.
*        if source_line = seop_src_inactive_new.
*          mac__module_raise seo_method_get_source sy-subrc inactive_new.
*        endif.
*      endif.
*    else.
*      mac__module_raise seo_method_get_source sy-subrc version_not_existing.
*    endif.
*    source[] = source_expanded[].
*  else.
*    read report filename into source_expanded.
*    source[] = source_expanded[].
*    read table source_expanded into source_line index 1.
*    if sy-subrc = 0.
*      if source_line = seop_src_inactive_new.
*        mac__module_raise seo_method_get_source sy-subrc inactive_new.
*      elseif source_line = seop_src_inactive_deleted.
*        mac__module_raise seo_method_get_source sy-subrc inactive_delete.
*      endif.
*    endif.
*  endif.

endmethod.

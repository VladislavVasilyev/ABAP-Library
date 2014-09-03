method SEO_CLASS_GET_TYPE_SOURCE.

  data
  : filename type progstruc
  , dest type zvcst_t__char255
  , type type vseotype
  .

  refresh: source, dest.

  call function 'SEO_TYPE_GET'
    exporting
      typkey  = typkey
      version = seoc_version_inactive
    importing
      type    = type
    exceptions
      others  = 1.
  if sy-subrc <> 0.
    mac__module_raise seo_class_get_type_source sy-subrc not_existing.
  endif.
  if type-typtype <> seoo_typtype_others.
    mac__module_raise seo_class_get_type_source sy-subrc not_edited.
  endif.
* check if internal class entry exists
  system-call query class typkey-clsname.
  if sy-subrc <> 0.
    mac__module_raise seo_class_get_type_source sy-subrc class_not_existing .
    return.
  endif.

  clear filename.
  filename-rootname = typkey-clsname.
  translate filename-rootname using ' ='.

  case type-exposure.
    when seoc_exposure_public.
      filename-categorya = srext_ext_class_public(1).
      filename-codea = srext_ext_class_public+1(1).
    when seoc_exposure_protected.
      filename-categorya = srext_ext_class_protected(1).
      filename-codea = srext_ext_class_protected+1(1).
    when seoc_exposure_private.
      filename-categorya = srext_ext_class_private(1).
      filename-codea = srext_ext_class_private+1(1).
  endcase.

  read report filename
    into dest.

* extract_type_source

  data
  : line     type zvcst_s__char255
  , irow1    type seotype-srcrow1
  , irow2    type seotype-srcrow2
  , icolumn2 type seotype-srccolumn2
  .

  check type-srcrow2 >= type-srcrow1
    and type-srcrow1 > 0
    and type-srccolumn1 >= 0
    and type-srccolumn2 > 0.


  irow1    = type-srcrow1 + 1.
  irow2    = type-srcrow2 - 1.
  icolumn2 = type-srccolumn2 + 1.

  if type-srcrow1 = type-srcrow2.
    read table dest
      into line
      index type-srcrow1.
    check sy-subrc = 0.
    line = line(icolumn2).
*    shift line by column1 places.
    translate line using '. '.
    append line to source.
  else.
    read table dest
      into line
      index type-srcrow1.
    check sy-subrc = 0.
*    shift line by column1 places.
    append line to source.
    if irow1 <> type-srcrow2.
      loop at dest
        into line
        from irow1 to irow2.
        append line to source.
      endloop.
    endif.
    read table dest
      into line
      index type-srcrow2.
    check sy-subrc = 0.
    line = line(icolumn2).
    append line to source.
  endif.

endmethod.

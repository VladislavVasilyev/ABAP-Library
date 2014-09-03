method create_object.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_v__name type string
  , ld_v__objname type rsedd0-typegroup
  , ld_s__text type ddtypet.

  field-symbols
  : <ld_s__type>      type ty_s__type
  , <ld_s__tadir>     type zvcst_s__tadir
  .

  assign i_r__source->* to <ld_s__type>.

  if not <ld_s__type>-texts is initial.
    loop at <ld_s__type>-texts into ld_s__text
         where ddlanguage eq sy-langu.
    endloop.
    if sy-subrc ne 0.
      read table <ld_s__type>-texts into ld_s__text index 1.
    endif.
  else.
    move 'Oasis' to ld_s__text-ddtext.
  endif.

  move <ld_s__type>-name to ld_v__objname.

  try.

      call method zcl_vcs_r3tr___tech=>rs_dd_tygr_insert_sources
        exporting
          typegroupname = ld_v__objname
          ddtext        = ld_s__text-ddtext
          corrnum       = ' '
          devclass      = <ld_s__tadir>-devclass
          source        = <ld_s__type>-source.

      concatenate zvcsc_r3tr_type-type ld_v__objname into ld_v__name.

      call method zcl_vcs_r3tr___tech=>rs_corr_insert
        exporting
          object          = ld_v__name
          object_class    = 'DICT'
          mode            = 'I'
          devclass        = <ld_s__tadir>-devclass
          author          = <ld_s__tadir>-author
          master_language = <ld_s__tadir>-masterlang
          genflag         = <ld_s__tadir>-genflag
          suppress_dialog = 'X'.

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_create__r3tr
        exporting
          previous = lr_x__call_module_error
          object = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

endmethod.

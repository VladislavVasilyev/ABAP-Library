method CREATE_PATH.

  data
  : ld_v__path      type string value ``
  , ld_v__path_dev  type string
  , ld_v__dir       type string
  , ld_v__tabclass  type string
  .

  field-symbols
  : <ld_s__bpcdir>  type zvcst_s__tadir
  .

  assign i_s__dir to <ld_s__bpcdir>.

  if i_s__path-f_sys = abap_true.
    concatenate zvcsc_bpc `\` into ld_v__path.
  endif.

  if i_s__path-f_pac = abap_true.
    if <ld_s__bpcdir>-appset is not initial.
      concatenate ld_v__path <ld_s__bpcdir>-appset `\` into ld_v__path.
    endif.

    if <ld_s__bpcdir>-application is not initial.
      concatenate ld_v__path <ld_s__bpcdir>-application `\` into ld_v__path.
    endif.
  endif.

  if i_s__path-f_dir = abap_true.
    case <ld_s__bpcdir>-object.
      when zvcsc_bpc_type-sclo. ld_v__dir = zvcsc_bpc_path-sclo.
    endcase.
    concatenate ld_v__path ld_v__dir `\` into ld_v__path.
  endif.

*  if i_s__path-f_ele = abap_true.
*    concatenate ld_v__path i_s__bpcdir-obj_name `\` into ld_v__path.
*  endif.

  concatenate <ld_s__bpcdir>-object `.` <ld_s__bpcdir>-obj_name into e_v__xmlname.
  concatenate <ld_s__bpcdir>-object `.` <ld_s__bpcdir>-obj_name into e_v__mastername.
  replace `.LGF` in e_v__mastername with ``.

  e_v__extsrcname = `lgf`.

  concatenate i_s__path-path ld_v__path                       into e_v__path.


endmethod.

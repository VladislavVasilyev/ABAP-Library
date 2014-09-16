method create_path.

  data
  : ld_v__path              type string value ``
  , ld_v__path_dev          type string
  , ld_v__dir               type string
  , ld_v__team_id           type uj_team_id
  , ld_v__group_id          type uj_pack_grp_id
  , ld_v__package_id        type uj_package_id.

  field-symbols
  : <ld_s__bpcdir>          type zvcst_s__tadir
  , <ld_s__source>          type zvcst_s__download
  .


  loop at gd_t__source assigning <ld_s__source>.

    assign <ld_s__source>-header to <ld_s__bpcdir>.

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

    split <ld_s__bpcdir>-obj_name at `/` into ld_v__team_id ld_v__group_id ld_v__package_id.

    if i_s__path-f_dir = abap_true.
      if ld_v__team_id is initial.
        ld_v__team_id = `Company`.
      endif.
      concatenate ld_v__path zvcsc_bpc_path-pack `\` ld_v__team_id `\` ld_v__group_id `\` into ld_v__path.
    endif.

*  if i_s__path-f_ele = abap_true.
*    concatenate ld_v__path i_s__bpcdir-obj_name `\` into ld_v__path.
*  endif.

    concatenate <ld_s__bpcdir>-object `.` ld_v__package_id into <ld_s__source>-xmlname.
    concatenate <ld_s__bpcdir>-object `.` ld_v__package_id into <ld_s__source>-mastername.
    <ld_s__source>-extsrcname = `txt`.
    concatenate i_s__path-path ld_v__path into <ld_s__source>-path.

  endloop.

endmethod.

method create_path.

  data
  : ld_v__path              type string value ``
  , ld_v__path_dev          type string
  , ld_v__dir               type string
  , ld_v__team_id           type uj_team_id
  , ld_v__group_id          type uj_pack_grp_id
  , ld_v__dimension         type uj_dim_name.

  field-symbols
  : <ld_s__bpcdir>          type zvcst_s__tadir
  , <ld_s__source>          type zvcst_s__download
  , <ld_s__dimension>       type uja_dimension
  , <ld_s__content> type ty_s__content
  .


  loop at gd_t__source assigning <ld_s__source>.

    assign <ld_s__source>-header to <ld_s__bpcdir>.

    if i_s__path-f_sys = abap_true.
      concatenate zvcsc_bpc `\` into ld_v__path.
    endif.

    if i_s__path-f_pac = abap_true.
      if <ld_s__bpcdir>-appset is not initial.
        concatenate ld_v__path <ld_s__bpcdir>-appset `\` `$DIMENSION` into ld_v__path.
      endif.
    endif.

    if i_s__path-f_dir = abap_true.
      concatenate ld_v__path `\` <ld_s__bpcdir>-obj_name `\` into ld_v__path.
    endif.

    concatenate <ld_s__bpcdir>-object `.` <ld_s__bpcdir>-obj_name into <ld_s__source>-xmlname.
    concatenate <ld_s__bpcdir>-object `.` <ld_s__bpcdir>-obj_name into <ld_s__source>-mastername.

    concatenate i_s__path-path ld_v__path into <ld_s__source>-path.

  endloop.

  loop at gd_t__content assigning <ld_s__content>.

    if i_s__path-f_sys = abap_true.
      concatenate zvcsc_bpc `\` into ld_v__path.
    endif.

    if i_s__path-f_pac = abap_true.
      if <ld_s__content>-appset is not initial.
        concatenate ld_v__path <ld_s__bpcdir>-appset `\` `$DIMENSION` into ld_v__path.
      endif.
    endif.

    if i_s__path-f_dir = abap_true.
      concatenate ld_v__path `\` <ld_s__content>-dimension `\` into ld_v__path.
    endif.

    concatenate i_s__path-path ld_v__path into <ld_s__content>-path.


  endloop.


endmethod.

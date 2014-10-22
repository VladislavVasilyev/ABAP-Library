method create_path.

  data
  : ld_v__path      type string value ``
  , ld_v__path_dev  type string
  , ld_v__dir       type string
  , ld_v__tabclass  type string
  , ld_t__name      type table of string
  , ld_v__obj_name  type string
  .

  field-symbols
  : <ld_s__bpcdir>  type zvcst_s__tadir
  , <ld_s__source>  type ty_s__source
  .

  loop at gd_t__source_excl assigning <ld_s__source>.


    assign <ld_s__source>-source-header to <ld_s__bpcdir>.

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
        when zvcsc_bpc_type-excl. ld_v__dir = zvcsc_bpc_path-xltp.
      endcase.
      concatenate ld_v__path ld_v__dir `\` into ld_v__path.
    endif.


    split <ld_s__bpcdir>-obj_name at `\` into table ld_t__name.

    loop at ld_t__name into ld_v__obj_name.
      check lines( ld_t__name ) > sy-tabix.
      concatenate ld_v__path ld_v__obj_name `\` into ld_v__path.
    endloop.

    concatenate <ld_s__bpcdir>-object `.` ld_v__obj_name into <ld_s__source>-source-xmlname.
    concatenate <ld_s__bpcdir>-object `.` ld_v__obj_name into <ld_s__source>-source-mastername.
    concatenate <ld_s__bpcdir>-object `.` ld_v__obj_name into <ld_s__source>-content-filename.

    concatenate i_s__path-path ld_v__path                       into <ld_s__source>-source-path.

  endloop.

  endmethod.

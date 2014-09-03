method PATHS.

  data
  : lr_o__object               type ref to zcl_vcs_objects_stack
  , ld_s__type                 type zvcst_s__object
  .

  field-symbols
  : <ld_s__download_object>    type zvcst_s__download
  .


  loop at zcl_vcs_objects_stack=>cd_t__objects_for_download
       assigning <ld_s__download_object>.

    ld_s__type = <ld_s__download_object>-type.


    check zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.
    lr_o__object ?= zcl_vcs_objects_stack=>get_object( ld_s__type ).

    try.
        call method lr_o__object->create_path
          exporting
            i_s__dir        = <ld_s__download_object>-header
            i_s__path       = cd_v__path
          importing
            e_v__path       = <ld_s__download_object>-path
            e_v__mastername = <ld_s__download_object>-mastername
            e_v__xmlname    = <ld_s__download_object>-xmlname
            e_v__extsrcname = <ld_s__download_object>-extsrcname.

        check <ld_s__download_object>-path is initial.
        <ld_s__download_object>-path = cd_v__path-path.

      catch cx_sy_move_cast_error cx_sy_dyn_call_error.
        continue.
    endtry.


  endloop.

endmethod.

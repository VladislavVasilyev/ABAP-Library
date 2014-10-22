method create_path.

  data
   : ld_v__path      type string value ``
   , ld_v__path_dev  type string
   , ld_v__dir       type string
   , ld_v__tabclass  type string
   .

  field-symbols
  : <ld_s__tadir>  type zvcst_s__tadir
  , <ld_s__source>   like line of gd_t__source
  .

  loop at gd_t__source assigning <ld_s__source>.
    assign <ld_s__source>-header to <ld_s__tadir>.

    if i_s__path-f_sys = abap_true.
      concatenate zvcsc_r3tr `\` into ld_v__path.
    endif.

    ld_v__path_dev = zcl_vcs__r3tr__devc=>get_pathdevclas( <ld_s__tadir>-devclass ).
    <ld_s__tadir>-pathdevc = ld_v__path_dev.

    if i_s__path-f_pac = abap_true.
      concatenate ld_v__path ld_v__path_dev `\` into ld_v__path.
    endif.

    if i_s__path-f_dir = abap_true.
      case <ld_s__tadir>-tabclass.
        when zvcsc_tabclass_type-transp . ld_v__dir = zvcsc_tabclass_path-transp .
        when zvcsc_tabclass_type-inttab . ld_v__dir = zvcsc_tabclass_path-inttab .
        when zvcsc_tabclass_type-cluster. ld_v__dir = zvcsc_tabclass_path-cluster.
        when zvcsc_tabclass_type-pool   . ld_v__dir = zvcsc_tabclass_path-pool   .
        when zvcsc_tabclass_type-view   . ld_v__dir = zvcsc_tabclass_path-view   .
        when zvcsc_tabclass_type-append . ld_v__dir = zvcsc_tabclass_path-append .
      endcase.

      concatenate ld_v__path ld_v__dir `\` into ld_v__path.
    endif.

    if i_s__path-f_ele = abap_true.
      concatenate ld_v__path <ld_s__tadir>-obj_name `\` into ld_v__path.
    endif.

    concatenate <ld_s__tadir>-object `.` <ld_s__tadir>-obj_name into <ld_s__source>-xmlname.
    concatenate i_s__path-path ld_v__path                       into <ld_s__source>-path.
  endloop.

endmethod.

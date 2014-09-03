method CREATE_PATH.

  data
   : ld_v__path      type string value ``
   , ld_v__path_dev  type string
   , ld_v__dir       type string
   , ld_v__tabclass  type string
   .

  field-symbols
  : <ld_s__tadir>  type zvcst_s__tadir
  .

  assign i_s__dir to <ld_s__tadir>.

  if i_s__path-f_sys = abap_true.
    concatenate zvcsc_r3tr `\` into ld_v__path.
  endif.

  if i_s__path-f_pac = abap_true.
    concatenate ld_v__path <ld_s__tadir>-pathdevc `\` into ld_v__path.
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

  concatenate <ld_s__tadir>-object `.` <ld_s__tadir>-obj_name into e_v__xmlname.
  concatenate i_s__path-path ld_v__path                       into e_v__path.

endmethod.

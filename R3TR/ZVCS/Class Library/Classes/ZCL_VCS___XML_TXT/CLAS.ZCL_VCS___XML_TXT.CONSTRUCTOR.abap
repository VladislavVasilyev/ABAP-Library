method constructor.

  data
  : ld_s__sourcenodepath like line of gd_t__sourcenodepath
  , ld_v__nodepath       type string
  .

  field-symbols
  : <ld_s__txtsource> like line of gd_s__source-txtnodepath
  .

  create object gr_o__xmldoc.

  move i_s__source-mastername to  gd_v__mastername.
  move i_s__source-xmlname    to  gd_v__xmlname.
  move i_s__source-extsrcname to  gd_v__extsrcname.

  gd_s__source   = i_s__source.

  ld_s__sourcenodepath-sign   = `I`.
  ld_s__sourcenodepath-option = `EQ`.

  loop at gd_s__source-txtnodepath
       assigning <ld_s__txtsource>.

    concatenate `/` gd_s__source-type <ld_s__txtsource>-pathnode into ld_v__nodepath.
    move ld_v__nodepath to ld_s__sourcenodepath-low.
    append ld_s__sourcenodepath to gd_t__sourcenodepath.


    concatenate `/` gd_s__source-type  <ld_s__txtsource>-pathname into ld_v__nodepath.
    move ld_v__nodepath to     ld_s__sourcenodepath-low.
    append ld_s__sourcenodepath to gd_t__sourcenodename.
  endloop.

  append '<?xml version="1.0" encoding="utf-8"?>' to gd_t__xmlformatdoc.

  gd_v__path   = i_s__source-path.
*  gd_v__prefix = i_v__prefix.

endmethod.

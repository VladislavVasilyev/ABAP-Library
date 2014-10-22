method download.

  data
  : ld_v__path      type string
  , lr_o__xml       type ref to zcl_vcs___xml_txt
  , ld_s__source    type zvcst_s__download
  .

  field-symbols
  : <ld_s__xml>     type ty_s__fgroup
  , <ld_s__source>  type zvcst_s__download
  .

  loop at gd_t__source assigning <ld_s__source>.
    call method zcl_vcs___xml_txt=>download
      exporting
        i_s__source = <ld_s__source>.
  endloop.

endmethod.

method download.

  data
  : ld_v__path      type string
  , lr_o__xml       type ref to zcl_vcs___xml_txt
  , ld_s__source    type zvcst_s__download
  .

  field-symbols
  : <ld_s__content> type ty_s__content
  , <ld_s__xml>     type ty_s__dimn
  , <ld_s__source>  type zvcst_s__download
  .

  loop at gd_t__source assigning <ld_s__source>.
    call method zcl_vcs___xml_txt=>download
      exporting
        i_s__source = <ld_s__source>.
  endloop.

  " Сохранение контента
  loop at gd_t__content assigning <ld_s__content>.

    concatenate <ld_s__content>-path <ld_s__content>-filename into ld_v__path.

    call method cl_gui_frontend_services=>gui_download
      exporting
        bin_filesize = <ld_s__content>-file_length
        filename     = ld_v__path
        filetype     = 'BIN'
      changing
        data_tab     = <ld_s__content>-content
      exceptions
        others       = 24.

  endloop.

endmethod.

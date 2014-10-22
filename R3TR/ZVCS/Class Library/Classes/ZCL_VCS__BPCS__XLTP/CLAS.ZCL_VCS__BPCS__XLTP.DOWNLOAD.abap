method download.

  data
   : ld_v__path      type string
   , lr_o__xml       type ref to zcl_vcs___xml_txt
   , ld_s__source    type zvcst_s__download
   .

  field-symbols
  : <ld_s__content> type ty_s__content
  , <ld_s__xml>     type ty_s__xltp
  , <ld_s__source>  type ty_s__source
  .

  loop at gd_t__source_excl assigning <ld_s__source>.

    call method zcl_vcs___xml_txt=>download
      exporting
        i_s__source = <ld_s__source>-source.

    " Сохранение контента

    concatenate <ld_s__source>-source-path <ld_s__source>-content-filename into ld_v__path.

    call method cl_gui_frontend_services=>gui_download
      exporting
        bin_filesize = <ld_s__source>-content-file_length
        filename     = ld_v__path
        filetype     = 'BIN'
      changing
        data_tab     = <ld_s__source>-content-content
      exceptions
        others       = 24.
 endloop.

endmethod.

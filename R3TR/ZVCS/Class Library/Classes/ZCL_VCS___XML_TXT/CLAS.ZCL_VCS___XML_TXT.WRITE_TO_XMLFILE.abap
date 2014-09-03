method write_to_xmlfile.

  data
  : ld_s__message type ty_s__download
  .

  concatenate gd_v__path gd_v__xmlname `.xml` into gd_v__xmlpath.

  ld_s__message-type = gd_s__source-header-object.
  ld_s__message-path = gd_v__path.
  concatenate gd_v__xmlname `.xml` into ld_s__message-name.

  cl_gui_frontend_services=>gui_download(
    exporting
      filename = gd_v__xmlpath
      codepage = `4110`
      trunc_trailing_blanks = `X`
      trunc_trailing_blanks_eol = `X`
*      write_bom = abap_true
      filetype = `ASC`
*        write_lf = ``
      importing
        filelength = ld_s__message-size
    changing
      data_tab = gd_t__xmlformatdoc "ld_t__utf_8
    exceptions
  others   = 24 ).

  append ld_s__message to gd_t__message.


endmethod.

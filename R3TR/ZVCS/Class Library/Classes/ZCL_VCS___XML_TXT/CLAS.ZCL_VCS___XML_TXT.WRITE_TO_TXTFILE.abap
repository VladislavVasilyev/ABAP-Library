method write_to_txtfile.

  data
  : ld_s__message type ty_s__download
  .


  field-symbols
  : <ld_s__txtsource> type zvcst_s__file_source
  .

  loop at gd_t__txtsource
       assigning <ld_s__txtsource>.

    concatenate gd_v__path <ld_s__txtsource>-filename into gd_v__xmlpath.

    ld_s__message-type = gd_s__source-header-object.
    ld_s__message-path = gd_v__path.
    ld_s__message-name = <ld_s__txtsource>-filename.

    cl_gui_frontend_services=>gui_download(
      exporting
        filename = gd_v__xmlpath
        codepage = `4110`
        trunc_trailing_blanks = `X`
        trunc_trailing_blanks_eol = `X`
*        write_bom = abap_true
        filetype = 'ASC'
*        write_lf = ``
      importing
        filelength = ld_s__message-size
      changing
        data_tab = <ld_s__txtsource>-source
      exceptions
    others   = 24 ).

    append ld_s__message to gd_t__message.

  endloop.


endmethod.

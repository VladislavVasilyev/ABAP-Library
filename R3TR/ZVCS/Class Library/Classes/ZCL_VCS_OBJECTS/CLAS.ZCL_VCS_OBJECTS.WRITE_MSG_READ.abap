method WRITE_MSG_READ.

  data
  : ld_v__size              type c length 6
  , ld_v__totalsize         type i
  , ld_v__lines             type i
  .

  field-symbols
  : <ld_s__message_download>  type zcl_vcs___xml_txt=>ty_s__download
  .

  if cd_t__message_download is not initial.
    uline.
    loop at cd_t__message_download assigning <ld_s__message_download>.
      add <ld_s__message_download>-size to ld_v__totalsize.
    endloop.

    ld_v__lines = lines( cd_t__message_download ).
    new-line.
    write: `Dowloand `, ld_v__totalsize no-gap, `bytes  in`,  ld_v__lines, `files`.
    uline.
    loop at cd_t__message_download assigning <ld_s__message_download>.

      ld_v__size = <ld_s__message_download>-size.
      new-line.
      write
      : ld_v__size right-justified color col_key
      , <ld_s__message_download>-type color col_key
      , <ld_s__message_download>-path no-gap color col_key
      , <ld_s__message_download>-name no-gap color col_total.

    endloop.
  endif.

endmethod.

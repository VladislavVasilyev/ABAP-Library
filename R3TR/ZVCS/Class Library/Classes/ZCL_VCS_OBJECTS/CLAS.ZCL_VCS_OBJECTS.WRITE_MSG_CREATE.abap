method WRITE_MSG_CREATE.

  data
  : text                    type string
  , ld_x__object            type ref to cx_root
  , ld_v__numerror          type c length 4
  , ld_v__nl                type c length 5
  , ld_v__size              type c length 6
  , ld_v__totalsize         type i
  , ld_s__message_download  type zcl_vcs___xml_txt=>ty_s__download
  , ld_v__lines             type i
  .

  field-symbols
  : <ld_s__error>             type ty_s__error_stack
  , <ld_s__message_create>    type ty_s__create
  .

  loop at cd_t__message_create assigning <ld_s__message_create>.
    write: / <ld_s__message_create>-pgmid color col_key, <ld_s__message_create>-type color col_key, <ld_s__message_create>-name color col_total.
  endloop.

endmethod.

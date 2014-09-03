method WRITE_MSG_ERROR.

  data
  : ld_v__text              type string
  , ld_x__object            type ref to cx_root
  , ld_v__numerror          type c length 4
  , ld_v__nl                type c length 5
  .

  field-symbols
  : <ld_s__error>             type ty_s__error_stack
  , <ld_s__message_create>    type ty_s__create
  .

  loop at cd_t__error_stack
       assigning <ld_s__error>.

    ld_v__numerror = sy-tabix.
    ld_x__object ?= <ld_s__error>-cx_ref.

    while ld_x__object is not initial.

      ld_v__text = ld_x__object->get_text( ).

      if sy-index = 1.
        write: / ld_v__numerror right-justified no-gap color col_key, `.` color col_key, ld_v__text color col_negative .
      else.
        new-line.
        ld_v__nl = `└─`.
        write:  ld_v__nl right-justified color col_key, ld_v__text color col_negative .
      endif.

      ld_x__object ?= ld_x__object->previous.
    endwhile.
  endloop.

endmethod.

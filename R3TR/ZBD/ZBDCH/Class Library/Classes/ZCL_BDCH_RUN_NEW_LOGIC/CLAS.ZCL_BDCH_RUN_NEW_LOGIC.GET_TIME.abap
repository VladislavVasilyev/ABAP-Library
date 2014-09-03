method get_time.

  data
  : ld_v__start_date    type string
  , ld_v__start_time    type string
  , ld_v__delta_time    type string.

  call method convert_time
    exporting
      i_v__start      = i_v__start
      i_v__end        = i_v__end
    importing
      e_v__data_start = ld_v__start_date
      e_v__time_start = ld_v__start_time
      e_v__delta_time = ld_v__delta_time.

    concatenate `[T. ` ld_v__start_date ` ` ld_v__start_time ` D. ` ld_v__delta_time `]` into e_v__text.

endmethod.

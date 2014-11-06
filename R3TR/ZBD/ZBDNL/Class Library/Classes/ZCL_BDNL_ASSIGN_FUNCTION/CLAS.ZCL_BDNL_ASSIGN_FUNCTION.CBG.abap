method cbg.

  data
  : ld_t__str type table of string
  .

  split i01 at `,` into table ld_t__str.

  read table ld_t__str index i02 into e.

endmethod.

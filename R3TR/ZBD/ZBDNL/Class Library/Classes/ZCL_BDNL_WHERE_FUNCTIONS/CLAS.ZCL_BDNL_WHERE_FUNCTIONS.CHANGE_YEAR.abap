method change_year.

  types ty_time type c length 8.

  data
  : ld_t__timelist type standard table of string
  , ld_v__timelist type string
  , ld_v__e        type line of zbnlt_t__param
  , ld_v__time     type ty_time
  , ld_v__year     type c length 4
  .

  ld_v__timelist = i01.
  ld_v__year = i02.

  condense ld_v__timelist no-gaps.
  split ld_v__timelist at `,` into table ld_t__timelist.

  loop at ld_t__timelist into ld_v__time.
    ld_v__time+0(4) = ld_v__year.
    append ld_v__time to e.
  endloop.

endmethod.

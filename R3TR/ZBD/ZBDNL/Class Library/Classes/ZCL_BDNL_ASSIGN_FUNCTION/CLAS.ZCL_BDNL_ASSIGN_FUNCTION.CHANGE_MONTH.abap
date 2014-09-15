method CHANGE_MONTH.

  data
  : var   type c length 8
  , year  type c length 4
  .

  var = i01.
  year = i02.

  var+0(4) = year.

  e = var.

endmethod.

method CHANGE_MONTH.

  data
  : var   type c length 8
  , month  type c length 4
  .

  var = i01.
  month = i02.

  var+5(3) = month.

  e = var.

endmethod.

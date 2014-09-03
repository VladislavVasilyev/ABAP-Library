method GET_TIME.

  data
  : period   type c length 3
  , year     type c length 4
  , var      type c length 8
  .

  year = i01.
  period = i02.

  concatenate year `.` period into var.

  e = var.

endmethod.

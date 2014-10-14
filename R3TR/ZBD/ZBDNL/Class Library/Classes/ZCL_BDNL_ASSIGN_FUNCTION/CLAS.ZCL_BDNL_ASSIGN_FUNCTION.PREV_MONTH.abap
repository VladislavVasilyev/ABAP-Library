method prev_month.

  data
  : time_num  type string
  , year      type c length 4
  , month     type i
  , e_time    type c length 8 value `YYYY.MMM`
  .

  time_num = __get_time( i01 ).

  year = time_num(4).
  month = time_num+4(2).

  if time_num+4(2) = 01.
    month = 12.
    year = year - 1.
  else.
    month = month - 1.
  endif.

  e_time(4) = year.
  e_time+5(3) = __GET_TIME_MONTH( month ).

endmethod.

method stop_program.
  check on = abap_true.

  get time stamp field time.

  do.
    mac__subtract_time.

    " для выхода из цикла переменной EXIT присвойте значение больше 60
    break-point.
    if exit > 60.exit.endif.

  enddo.

endmethod.

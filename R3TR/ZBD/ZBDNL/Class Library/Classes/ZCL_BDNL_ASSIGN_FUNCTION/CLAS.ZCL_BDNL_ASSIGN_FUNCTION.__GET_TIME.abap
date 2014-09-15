method __get_time.

  data ld_v__time type string .

  ld_v__time = time.

  case ld_v__time+5(3).
    when `JAN`. concatenate ld_v__time(4) `01` into  ld_v__time.
    when `FEB`. concatenate ld_v__time(4) `02` into  ld_v__time.
    when `MAR`. concatenate ld_v__time(4) `03` into  ld_v__time.
    when `APR`. concatenate ld_v__time(4) `04` into  ld_v__time.
    when `MAY`. concatenate ld_v__time(4) `05` into  ld_v__time.
    when `JUN`. concatenate ld_v__time(4) `06` into  ld_v__time.
    when `JUL`. concatenate ld_v__time(4) `07` into  ld_v__time.
    when `AUG`. concatenate ld_v__time(4) `08` into  ld_v__time.
    when `SEP`. concatenate ld_v__time(4) `09` into  ld_v__time.
    when `OCT`. concatenate ld_v__time(4) `10` into  ld_v__time.
    when `NOV`. concatenate ld_v__time(4) `11` into  ld_v__time.
    when `DEC`. concatenate ld_v__time(4) `12` into  ld_v__time.
    when others.
      raise exception type zcx_bdnl_skip_assign.
  endcase.

  e = ld_v__time.

endmethod.

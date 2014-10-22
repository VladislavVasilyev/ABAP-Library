method __get_time_month.

  case month.
    when  1. e = `JAN`.
    when  2. e = `FEB`.
    when  3. e = `MAR`.
    when  4. e = `APR`.
    when  5. e = `MAY`.
    when  6. e = `JUN`.
    when  7. e = `JUL`.
    when  8. e = `AUG`.
    when  9. e = `SEP`.
    when 10. e = `OCT`.
    when 11. e = `NOV`.
    when 12. e = `DEC`.
    when others.
      raise exception type zcx_bdnl_skip_assign.
  endcase.

endmethod.

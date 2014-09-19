method get_excel_date.

  constants
  : excel_date type datum value `19000101`
  .

  data
  : idate type i
  , date  type datum
  , edate type i
  .

  if I01 is initial.
    e = 0.
    exit.
  endif.


  concatenate i01+6(4) i01+3(2) i01(2) into date.

  edate = excel_date.
  subtract 2 from edate.

  idate = date.

  edate = idate - edate .
  e = edate.

endmethod.

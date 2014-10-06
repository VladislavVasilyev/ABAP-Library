method leftsym.

  data
  : length type i
  , offset type i
  .

  if i02 is supplied and i03 is supplied.
    offset = i02.
    length = i03.
    e = i01+offset(length).
  elseif i02 is supplied.
    offset = i02.
    e = i01+offset.
  elseif i03 is supplied.
    length = i03.
    e = i01(length).
  else.
    e = i01.
  endif.

endmethod.

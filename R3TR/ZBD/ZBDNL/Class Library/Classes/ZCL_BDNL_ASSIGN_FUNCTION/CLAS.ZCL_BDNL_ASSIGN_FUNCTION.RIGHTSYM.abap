method rightsym.

  data
  : length type i
  , offset type i
  , strlen type i
  .

  strlen = strlen( i01 ).

  if i02 is supplied and i03 is supplied.
    offset = I02.
    length = i03.
    offset = strlen( i01 ) - ( offset + length ).
    e = i01+offset(length).
  elseif i02 is supplied.
    offset = i02.
    length = strlen - offset.
    e = i01+0(length).
  elseif i03 is supplied.
    length = i03.
    offset = strlen( i01 ) - ( length ).
    e = i01+offset(length).
  else.
    e = i01.
  endif.

endmethod.

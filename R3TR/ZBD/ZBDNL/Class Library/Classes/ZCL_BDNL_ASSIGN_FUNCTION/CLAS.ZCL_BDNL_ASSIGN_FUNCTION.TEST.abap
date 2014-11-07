method test.

  data
  : ld_s__string type string
  .

  if i02 is not supplied and i03 is not supplied.
    e = i01.
  elseif i02 is supplied and i03 is not supplied.
    concatenate i01 i02 into ld_s__string.
  elseif i03 is supplied and i02 is supplied.
    concatenate i01 i02 i03 into ld_s__string.
  elseif i03 is supplied and i02 is not supplied.
    concatenate i01 i03 into ld_s__string.
  endif.

*  break-point.


  e = ld_s__string.



endmethod.

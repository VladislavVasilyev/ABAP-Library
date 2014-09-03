method get_space_text.
  data
  : ld_v__index type i
  .

  ld_v__index = i_v__size - 1.

  e_v__text = ` `.
  do ld_v__index times.
    concatenate e_v__text ` ` into e_v__text.
  enddo.

endmethod.

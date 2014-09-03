method get_nr_pack.

  data
  : ld_v__str  type string
  , ld_v__len  type i
  , ld_v__let  type string
  , ld_v__size type i
  .

  if i_v__size < 4.
    ld_v__size = 4 - 1.
  else.
    ld_v__size = i_v__size - 1.
  endif.

  ld_v__let =  ` `.

  do ld_v__size times.
    concatenate ld_v__let ` ` into ld_v__let.
  enddo.

  if i_v__nr_pack = -1.
    ld_v__str = `FULL`.
  else.
    ld_v__str = i_v__nr_pack.
  endif.

  concatenate ld_v__let ld_v__str into e_v__text.
  ld_v__len = strlen( e_v__text ) - i_v__size.
  e_v__text   = e_v__text+ld_v__len(i_v__size).

endmethod.

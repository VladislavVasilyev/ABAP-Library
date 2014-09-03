method get_nr_pack.

  data
  : ld_v__str  type string
  , ld_v__len  type i
  , ld_v__let  type string
  , ld_v__size type i
  .

  clear ld_v__let.

  ld_v__let =  ` `.

  do i_v__size times.
    concatenate ld_v__let ` ` into ld_v__let.
  enddo.

  ld_v__str = i_v__nr_pack.

  concatenate ld_v__let ld_v__str into e_v__text.
  ld_v__len = strlen( e_v__text ) - i_v__size - 1 .
  e_v__text   = e_v__text+ld_v__len(i_v__size).

endmethod.

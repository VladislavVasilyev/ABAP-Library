method get_nr_rows.

  data
  : ld_v__str       type string
  , ld_v__len       type i
  , ld_v__let       type string
  , ld_v__size      type i
  , ld_v__numrec    type string
  , ld_v__numsup    type string
  , ld_v__submit    type string
  , ld_v__fail      type string
  , ld_v__succes    type string
  .

  if i_v__size < 6.
    ld_v__size = 6 - 1.
  else.
    ld_v__size = i_v__size - 1.
  endif.

  ld_v__let =  ` `.

  do ld_v__size times.
    concatenate ld_v__let ` ` into ld_v__let.
  enddo.


  if i_s__read is supplied.
    ld_v__numrec = i_s__read-num_rec.
    ld_v__numsup = i_s__read-sup_rec.

    concatenate ld_v__let ld_v__numrec  into ld_v__numrec.
    ld_v__len      = strlen( ld_v__numrec ) - i_v__size.
    ld_v__numrec   = ld_v__numrec+ld_v__len(ld_v__size).
    concatenate `[R. ` ld_v__numrec `]` into ld_v__numrec.

    concatenate ld_v__let ld_v__numsup  into ld_v__numsup.
    ld_v__len      = strlen( ld_v__numsup ) - i_v__size.
    ld_v__numsup   = ld_v__numsup+ld_v__len(ld_v__size).
    concatenate `[Z. ` ld_v__numsup `]` into ld_v__numsup.

    if i_s__read-num_rec = i_s__read-sup_rec.
      ld_v__size = strlen( ld_v__numsup ).
      ld_v__numsup = get_space_text( ld_v__size ).
    endif.

    concatenate ld_v__numrec ld_v__numsup into e_v__text.

  elseif i_s__write is supplied.
    ld_v__submit = i_s__write-status_records-nr_submit.
    ld_v__fail   = i_s__write-status_records-nr_fail.
    ld_v__succes = i_s__write-status_records-nr_success.

    concatenate ld_v__let ld_v__submit  into ld_v__submit.
    ld_v__len    = strlen( ld_v__submit ) - i_v__size.
    ld_v__submit = ld_v__submit+ld_v__len(ld_v__size).
    concatenate `[S. ` ld_v__submit `]` into ld_v__submit.

    concatenate ld_v__let ld_v__succes  into ld_v__succes.
    ld_v__len    = strlen( ld_v__succes ) - i_v__size.
    ld_v__succes = ld_v__succes+ld_v__len(ld_v__size).
    concatenate `[W. ` ld_v__succes `]` into ld_v__succes.

    concatenate ld_v__let ld_v__fail  into ld_v__fail.
    ld_v__len    = strlen( ld_v__fail ) - i_v__size.
    ld_v__fail   = ld_v__fail+ld_v__len(ld_v__size).
    concatenate `[E. ` ld_v__fail `]` into ld_v__fail.

    if i_s__write-status_records-nr_fail is initial.
      ld_v__size = strlen( ld_v__fail ).
      ld_v__fail = get_space_text( ld_v__size ).
    endif.
    concatenate ld_v__succes ld_v__fail into e_v__text.
  endif.

endmethod.

method CHANGE_TIME_IN_FILTER.

  data ld_s__sel type uj0_s_sel.

  field-symbols
  : <ld_s__sel> type uj0_s_sel
  , <ls_s__cv>  type UJK_S_CV
  , <member>    type UJ_DIM_MEMBER
  .

  read table cv with key DIMENSION = `TIME` assigning <ls_s__cv>.
  check sy-subrc = 0.

  ld_s__sel-dimension = `TIME`.
  ld_s__sel-sign = `I`.
  ld_s__sel-option = `EQ`.


  LOOP AT <ls_s__cv>-member into ld_s__sel-low.

    ld_s__sel-low+0(4) = year.

    append ld_s__sel to sel.
  ENDLOOP.

endmethod.

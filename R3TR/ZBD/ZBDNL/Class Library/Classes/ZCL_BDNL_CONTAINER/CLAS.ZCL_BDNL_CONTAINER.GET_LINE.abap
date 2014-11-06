method get_line.

  data
  : lr_s__line type ref to data
  , ld_v__cnt  type i
  , ld_v__str  type string
  .

  field-symbols
  : <ld_s__line> type any
  , <ld_v__elem> type any
  .

  lr_s__line = gr_o__container->get_ref_line( ).

  if lr_s__line is bound.
    assign lr_s__line->* to <ld_s__line>.

    do.
      add 1 to ld_v__cnt.

      assign component ld_v__cnt of structure <ld_s__line> to <ld_v__elem>.

      if sy-subrc = 0.
        ld_v__str = <ld_v__elem>.

        if ld_v__cnt = 1.
          line =  ld_v__str.
        else.
          concatenate line ` | ` ld_v__str into line.
        endif.
      else.
        exit.
      endif.
    enddo.
  endif.

endmethod.

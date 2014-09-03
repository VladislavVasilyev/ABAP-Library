method check_tokens.

  data
  : ld_v__tokens type string
  .

  ld_v__tokens = get_tokens( q = q ).

  if f_nospace = abap_true.
    condense ld_v__tokens no-gaps.
  endif.

  find first occurrence of regex regex in ld_v__tokens.

  check sy-subrc = 0.
  check = abap_true.

endmethod.

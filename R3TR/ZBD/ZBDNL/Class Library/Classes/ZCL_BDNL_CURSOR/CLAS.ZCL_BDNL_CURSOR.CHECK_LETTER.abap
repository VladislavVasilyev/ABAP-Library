method check_letter.

  field-symbols
  : <ld_s__token_list> type zbnlt_s__match_res
  .

  read table gd_t__tokenlist
       index gd_v__index
       assigning <ld_s__token_list>.

  if <ld_s__token_list>-f_letter = abap_true.
    e = abap_true.
  else.
    e = abap_false.
  endif.

endmethod.

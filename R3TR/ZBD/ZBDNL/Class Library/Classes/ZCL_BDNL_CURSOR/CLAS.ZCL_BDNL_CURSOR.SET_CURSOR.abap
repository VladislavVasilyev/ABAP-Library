method SET_CURSOR.

  data
  : ld_v__tabix type i.
  .

  field-symbols
  : <ld_s__token_list> type zbnlt_s__match_res
  .

  loop at gd_t__tokenlist assigning <ld_s__token_list>
       where esc ne abap_true.
    ld_v__tabix = sy-tabix.

    if <ld_s__token_list>-token = word.
      index = gd_v__index = ld_v__tabix.
      if fesc = abap_true.
        <ld_s__token_list>-esc = abap_true.
        gd_v__index = ld_v__tabix + 1.
      endif.

      return.
    endif.

    if <ld_s__token_list>-token = escape.
        gd_v__index = ld_v__tabix.
        index = -1.
        return.
    endif.

  endloop.

  gd_v__index = ld_v__tabix.
  index = -1.

endmethod.

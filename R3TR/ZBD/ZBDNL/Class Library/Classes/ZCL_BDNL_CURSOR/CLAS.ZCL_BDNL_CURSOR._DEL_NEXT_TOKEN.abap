method _DEL_NEXT_TOKEN.
" К удалению
*  data
*   : ld_v__from   type i
*   .
*
*  field-symbols
*  : <ld_s__token_list> type zbnlt_s__match_res
*  .
*
*  if gd_v__index = 0.
*    ld_v__from = 1.
*  else.
*    ld_v__from = gd_v__index.
*  endif.
*
*  if ld_v__from > lines( gd_t__tokenlist ).
*    index = -1.
*  else.
*    loop at gd_t__tokenlist
*         from ld_v__from
*         assigning <ld_s__token_list>
*         where esc ne abap_true.
*
*      gd_v__index = sy-tabix.
*      exit.
*    endloop.
*
*    index = gd_v__index.
*  endif.

endmethod.

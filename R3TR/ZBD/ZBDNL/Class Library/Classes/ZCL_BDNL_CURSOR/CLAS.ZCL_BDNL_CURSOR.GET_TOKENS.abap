method get_tokens.

  data
  : ld_v__from   type i
  , ld_v__to     type i
  , ld_v__token  type string
  , ld_v__last_tok type string
  .

  field-symbols
  : <ld_s__token_list> type zbnlt_s__match_res
  .

  if gd_v__index = 0.
    ld_v__from = 1.
  else.
    ld_v__from = gd_v__index.
  endif.

  ld_v__to = ld_v__from + q - 1.

  loop at gd_t__tokenlist
     from ld_v__from
     to   ld_v__to
     assigning <ld_s__token_list>
     where esc ne abap_true.

    if sy-tabix = ld_v__from.
      tokens = <ld_s__token_list>-token.
    elseif <ld_s__token_list>-token = zblnc_keyword-dot   or
           <ld_s__token_list>-token = zblnc_keyword-tilde or
           ld_v__last_tok = zblnc_keyword-tilde .
      concatenate tokens <ld_s__token_list>-token into tokens.
    else.
      concatenate tokens <ld_s__token_list>-token into tokens separated by space.
    endif.

    ld_v__last_tok = <ld_s__token_list>-token.
  endloop.

  if f_nospace = abap_true.
    condense tokens no-gaps.
  endif.

endmethod.

method get_selection_rspc.

  data
  : ld_t__varsetting          type standard table of zbpc_varsetting
  , ld_v__par_name            type rspc_variant
  , ld_f__initpar             type rs_bool
  , ld_v__len                 type i
  , ld_t__param               type table of string
  , ld_v__param               type string
  , ld_v__value               type string
  , ld_v__lenght              type i
  , ld_v__offset              type i
  , ld_t__results             type match_result_tab
  , ld_v__tabix               type i
  .

  field-symbols
  : <ld_s__varsetting>        type zbpc_varsetting
  , <ld_s__results>           type match_result
  .

  select par_name
    into ld_v__par_name
    from zbpc_varsetting
   where rspc_var = i_v__rspc_var
     and par_name like `\%%\%` escape '\'
   group by par_name.

    select par_name value
      into corresponding fields of table ld_t__varsetting
      from zbpc_varsetting
     where rspc_var = i_v__rspc_var
       and par_name = ld_v__par_name.

    check sy-subrc = 0.

    find regex `\%[A-Z0-9\_]+\%` in ld_v__par_name.

    check sy-subrc = 0.
    ld_v__par_name = ld_v__par_name+1.
    ld_v__len      = strlen( ld_v__par_name ) - 1.
    ld_v__par_name = ld_v__par_name(ld_v__len).
    concatenate `|DIMENSION:` ld_v__par_name `|` into ld_v__param.


    loop at ld_t__varsetting
      assigning <ld_s__varsetting>.

      ld_v__tabix = sy-tabix.

      while sy-subrc = 0.
        find all occurrences of regex `(\$[A-Z0-9\_]+\$|\%[A-Z0-9\_]+\%)` in <ld_s__varsetting>-value match offset ld_v__offset match length ld_v__lenght ignoring case.

        if sy-subrc = 0.
          ld_v__value = <ld_s__varsetting>-value+ld_v__offset(ld_v__lenght).
          ld_v__value = get_value_rspc( ld_v__value ).

          replace section offset ld_v__offset length ld_v__lenght of <ld_s__varsetting>-value with ld_v__value.
        endif.
      endwhile.

      if ld_v__tabix = 1.
        concatenate ld_v__param     <ld_s__varsetting>-value into ld_v__param.
      else.
        concatenate ld_v__param `,` <ld_s__varsetting>-value into ld_v__param.
      endif.
    endloop.

    concatenate ld_v__param `|` into ld_v__param.

    append ld_v__param to ld_t__param.

  endselect.

  loop at ld_t__param
       into ld_v__param.
    if sy-tabix = 1.
      concatenate `@@@SAVE@@@@@@EXPAND@@@` ld_v__param into d_selection.
    else.
      concatenate d_selection ld_v__param into d_selection.
    endif.
  endloop.

  condense d_selection no-gaps.

endmethod.

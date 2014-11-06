method create_token.

  data
   : ld_v__offset             type i
   , ld_t__results            type match_result_tab
   , ld_s__results            type match_result
   , ld_s__tokenlist          type zbnlt_s__match_res
   , ld_s__variable           type zbnlt_s__variable
   , ld_v__i                  type i
   , ld_f__conc               type rs_bool
   , ld_i__nsymbol            type i
   , ld_f__lsymbol            type rs_bool
   , ld_f__rsymbol            type rs_bool
   , ld_v__length             type i
*   , ld_v__value              type string
   .

  field-symbols
*  : <ld_s__results>           type match_result
  : <ld_s__logic>             type zbnlt_s__lgfsource
  , <ld_s__tokenlist>         type zbnlt_s__match_res
  , <ld_s__variable>          type zbnlt_s__variable
  , <ld_v__value>             type string
  , <ld_v__cur_value>         type string
  .

  find all occurrences of regex `(`
                              & `\$([A-Z0-9\_]+)\>|`
                              & `\$([A-Z0-9\_]+)\$|`
                              & `\%([A-Z0-9\_]+)\%|`
                              & `\<([A-Z0-9\_]+)\>|`
                              & `\/(CPMB)\/([A-Z0-9\_]+)|`
                              & `([\~\(\)\.\*\\\-\+<>=\,\/])|`
                              & `(<=|<>|>=)|`
                              & `'([A-ZА-Я0-9\.\_\+\*\s\$\%\,\=]+)'|`
                              & `''|`
                              & `&&|`
                              & `(<\-|\->)|`
                              & `\$FILTER-POOLS\>|`
                              & `(\-\d+|\<\d+)(\>|\.\d+\>)|`    " вещественные числа
                              & `(\/\/\*|\*\\\\|\/\/)`          " коментарии
                              & `)`

 in table gd_t__logic results ld_t__results ignoring case.

  loop at ld_t__results
       into ld_s__results.

    clear ld_s__tokenlist.

    move-corresponding ld_s__results to ld_s__tokenlist.

    read table gd_t__logic index ld_s__results-line assigning <ld_s__logic>.

    ld_s__tokenlist-token = <ld_s__logic>+ld_s__results-offset(ld_s__results-length).

    if not ld_s__tokenlist-token cp `'*'`.
      translate ld_s__tokenlist-token to upper case.
    endif.

    if ld_s__tokenlist-token cp `'*'` or ld_s__tokenlist-token cp `''`.
      ld_s__tokenlist-f_letter = abap_true.
      replace all occurrences of `'` in ld_s__tokenlist-token with ``.
*      ld_s__tokenlist-value = ld_s__tokenlist-token.

      create data ld_s__tokenlist-refvalue type string.
      assign ld_s__tokenlist-refvalue->* to <ld_v__value>.
      <ld_v__value> = ld_s__tokenlist-token.

    elseif ld_s__tokenlist-token cp `$*$` or ld_s__tokenlist-token cp `%*%`.
      ld_s__tokenlist-f_variable = abap_true.

      read table gd_t__variable
           assigning <ld_s__variable>
           with key var = ld_s__tokenlist-token.

      if sy-subrc = 0.
        get reference of <ld_s__variable>-val into ld_s__tokenlist-refvalue.
      else.
        ld_s__variable-var = ld_s__tokenlist-token.
        clear ld_s__variable-val.
        insert ld_s__variable into table gd_t__variable assigning <ld_s__variable>.
        get reference of <ld_s__variable>-val into ld_s__tokenlist-refvalue.
      endif.
    elseif ld_s__tokenlist-token = zblnc_keyword-conc.
      ld_f__conc = abap_true.
      continue.
    elseif ld_s__tokenlist-token = zblnc_keyword-left_symbol.
      add 1 to ld_i__nsymbol.
      ld_f__lsymbol = abap_true.
      continue.
    elseif ld_s__tokenlist-token = zblnc_keyword-right_symbol.
      add 1 to ld_i__nsymbol.
      ld_f__rsymbol = abap_true.
      continue.

    else.
      find first occurrence of regex `^(\-\d+|\<\d+)($|\.\d+$)` in ld_s__tokenlist-token.
      if sy-subrc = 0.
        ld_s__tokenlist-f_num = abap_true.

        create data ld_s__tokenlist-refvalue type string.
        assign ld_s__tokenlist-refvalue->* to <ld_v__value>.
        <ld_v__value> = ld_s__tokenlist-token.

      endif.
    endif.

    if ld_s__tokenlist-refvalue is bound.
      assign ld_s__tokenlist-refvalue->* to <ld_v__value>.
      find first occurrence of regex `^(\-\d+|\<\d+)($|\.\d+$)` in <ld_v__value>.
      if sy-subrc = 0.
        ld_s__tokenlist-f_num = abap_true.
      endif.
    endif.

    if ld_f__conc = abap_true.
      ld_f__conc = abap_false.

      assign <ld_s__tokenlist>-refvalue->* to <ld_v__value>.
      assign ld_s__tokenlist-refvalue->* to <ld_v__cur_value>.

      concatenate <ld_v__value> <ld_v__cur_value> into <ld_v__value>.
      <ld_s__tokenlist>-token      = zblnc_keyword-conc.
      <ld_s__tokenlist>-f_variable = abap_true.
      <ld_s__tokenlist>-f_letter   = abap_false.
      <ld_s__tokenlist>-f_num      = abap_false.
      continue.
    endif.

    if ld_i__nsymbol > 0.
      case ld_i__nsymbol.
        when 1.
          assign ld_s__tokenlist-refvalue->* to <ld_v__cur_value>.
          ld_v__offset = <ld_v__cur_value>. " ld_s__tokenlist-value.
        when 2.
          if not ld_s__tokenlist-token = zblnc_keyword-open_parenthesis.
            " error.
          endif.
        when 3.
          assign ld_s__tokenlist-refvalue->* to <ld_v__cur_value>.
          ld_v__length = <ld_v__cur_value>." ld_s__tokenlist-value.
        when 4.
          if not ld_s__tokenlist-token = zblnc_keyword-close_parenthesis.
            " error.
          endif.

          if ld_f__lsymbol = abap_true.
            <ld_s__tokenlist>-token      = zblnc_keyword-left_symbol.
          elseif ld_f__rsymbol = abap_true.
            <ld_s__tokenlist>-token      = zblnc_keyword-right_symbol.

            assign <ld_s__tokenlist>-refvalue->* to <ld_v__value>.
            ld_v__offset = strlen( <ld_v__value> ) - ( ld_v__offset + ld_v__length ).
          endif.

          assign <ld_s__tokenlist>-refvalue->* to <ld_v__value>.
          <ld_v__value>      = <ld_v__value>+ld_v__offset(ld_v__length).
          <ld_s__tokenlist>-f_variable = abap_true.
          <ld_s__tokenlist>-f_letter   = abap_false.
          <ld_s__tokenlist>-f_num      = abap_false.
          clear: ld_i__nsymbol, ld_f__lsymbol.
          continue.

      endcase.

      add 1 to ld_i__nsymbol.
      continue.
    endif.

    insert ld_s__tokenlist into table gd_t__tokenlist assigning <ld_s__tokenlist>.
  endloop.

  " удаление коментариев //
  loop at gd_t__tokenlist
    assigning <ld_s__tokenlist>.

    if <ld_s__tokenlist>-token = `//`.
      ld_v__i = <ld_s__tokenlist>-line .
      delete gd_t__tokenlist.
      continue.
    endif.

    if ld_v__i = <ld_s__tokenlist>-line.
      delete gd_t__tokenlist.
    else.
      clear ld_v__i.
    endif.

  endloop.

  clear ld_v__i.

  " удаление блоков //* *\\, если не указан *\\ удаляется до конца текста
  loop at gd_t__tokenlist
    assigning <ld_s__tokenlist>.

    if <ld_s__tokenlist>-token = `//*`.
      add 1 to ld_v__i.
      delete gd_t__tokenlist.
      continue.
    endif.

    if <ld_s__tokenlist>-token = `*\\` and ld_v__i > 0.
      subtract 1 from ld_v__i.
      delete gd_t__tokenlist.
      continue.
    endif.

    if ld_v__i > 0.
      delete gd_t__tokenlist.
    endif.
  endloop.

  " удаление повторяющихся точек
  loop at gd_t__tokenlist
    assigning <ld_s__tokenlist>
    where token = zblnc_keyword-dot.

    if ld_v__i = sy-tabix.
      delete gd_t__tokenlist.
    else.
      ld_v__i = sy-tabix + 1.
    endif.
  endloop.

  loop at gd_t__tokenlist
       assigning <ld_s__tokenlist>
       where token = zblnc_keyword-cbg  " CHECK BOX GROUP
          or token = zblnc_keyword-stvarv
          or token = zblnc_keyword-subtract.

    case <ld_s__tokenlist>-token.
      when zblnc_keyword-cbg.
        get_cbg( sy-tabix ).
      when zblnc_keyword-stvarv.
        get_stvarv( sy-tabix ).
      when zblnc_keyword-subtract.
        get_subtract( sy-tabix ).
    endcase.
  endloop.

*  check_variables( ).
endmethod.

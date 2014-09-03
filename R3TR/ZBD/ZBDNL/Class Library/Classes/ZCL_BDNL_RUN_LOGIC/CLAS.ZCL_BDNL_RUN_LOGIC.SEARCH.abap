method search.

  data
  : ld_v__i          type i
  , ld_f__found      type rs_bool
  .

  field-symbols
  : <ld_s__search>   type  zbnlt_s__search
  , <ld_s__function> type zbnlt_s__function
  .

  if i > gd_s__rules-n_search. "calc

    assign( i = 1 f_found = abap_true ).

  else. "search

    read table gd_s__rules-search index i
         assigning <ld_s__search>.

    ld_v__i = i + 1.

    loop at <ld_s__search>-function assigning <ld_s__function>.
      call method zcl_bdnl_assign_function=>(<ld_s__function>-func_name)
        parameter-table
          <ld_s__function>-bindparam.
    endloop.

    while <ld_s__search>-object->next_line_1( <ld_s__search>-class ) eq zbd0c_found.
      ld_f__found = abap_true.
      search( ld_v__i ).
      check <ld_s__search>-f_uk eq abap_true.
      exit.
    endwhile.

    check ld_f__found = abap_false.
    assign( i = 1 f_found = abap_false ).
  endif.

endmethod.

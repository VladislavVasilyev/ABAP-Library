method search.

  data
  : ld_v__i                   type i
  , ld_f__found               type rs_bool
  , lr_x__root                type ref to cx_root
  .

  field-symbols
  : <ld_s__search>            type zbnlt_s__search
  , <ld_s__function>          type zbnlt_s__function
  .

  if i > gd_s__rules-n_search. "calc

    e_f__continue = assign( i = 1 f_found = abap_true ).

  else. "search

    read table gd_s__rules-search index i
         assigning <ld_s__search>.

    ld_v__i = i + 1.


    try.
        try.
            loop at <ld_s__search>-function assigning <ld_s__function>.
              call method zcl_bdnl_assign_function=>(<ld_s__function>-func_name)
                parameter-table
                  <ld_s__function>-bindparam.
            endloop.
          catch zcx_bdnl_skip_assign.
            raise exception type zcx_bdnl_skip_assign.
          catch cx_root into lr_x__root.                 "#EC CATCH_ALL
            raise exception type zcx_bdnl_work_func
                  exporting name      =  <ld_s__function>-func_name
                            bindparam = <ld_s__function>-bindparam
                            previous  = lr_x__root.
        endtry.


        loop at <ld_s__search>-check reference into gr_t__check.
          clear gd_v__check_index.
          if check_expr( abap_false ) = abap_false.
            zcl_bdnl_container=>add_skip( ).
            return.
          endif.
        endloop.

        if <ld_s__search>-class is bound.
          while <ld_s__search>-object->next_line_1( <ld_s__search>-class ) eq zbd0c_found.
            ld_f__found = abap_true.
            e_f__continue = search( ld_v__i ).
            check <ld_s__search>-f_uk eq abap_true.
            exit.
          endwhile.

          check ld_f__found = abap_false.
          e_f__continue = assign( i = 1 f_found = abap_false ).
        else." check only
          e_f__continue = search( ld_v__i ).
        endif.

      catch zcx_bdnl_skip_assign.
        zcl_bdnl_container=>add_skip( ).
        return.
    endtry.
  endif.

endmethod.

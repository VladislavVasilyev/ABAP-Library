method searchnext.

  data
  : ld_v__i                   type i
  , ld_f__found               type rs_bool
  , lr_x__root                type ref to cx_root
  , ld_t__rules               type ty_t__rules
  .

  field-symbols
  : <ld_s__search>            type zbnlt_s__search
  , <ld_s__function>          type zbnlt_s__function
  .

  if i > gd_t__rulenext-n_search.  "calc

    loop at gd_t__rules into gd_s__rules.
      check  search( 1 ) = abap_true.
      exit.
    endloop.
    return.
  else. "search

    read table gd_t__rulenext-search index i
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
            e_f__found = abap_false.
            return.
          endif.
        endloop.

        if <ld_s__search>-class is bound.
          while <ld_s__search>-object->next_line_1( <ld_s__search>-class ) eq zbd0c_found.
            ld_f__found = abap_true.
            e_f__found = searchnext( ld_v__i ).
            check <ld_s__search>-f_uk eq abap_true.
            exit.
          endwhile.
        else." check only
          e_f__found = searchnext( ld_v__i ).
        endif.

      catch zcx_bdnl_skip_assign.
        zcl_bdnl_container=>add_skip( ).
        e_f__found = abap_false.
        return.
    endtry.
  endif.

endmethod.

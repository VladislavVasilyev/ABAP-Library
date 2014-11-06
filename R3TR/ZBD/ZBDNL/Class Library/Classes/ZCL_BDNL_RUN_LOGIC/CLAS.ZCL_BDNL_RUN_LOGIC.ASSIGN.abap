method assign.

  data
  : ld_v__i               type i
  , ld_v__lines           type i
  , lr_x__root            type ref to cx_root
  .

  field-symbols
  : <ld_s__assign>        type zbnlt_s__assign
  , <ld_s__function>      type zbnlt_s__function
  .

  if f_found = abap_true.
    ld_v__lines = gd_s__rules-n_assign.
  else.
    ld_v__lines = gd_s__rules-n_assign_not_found.
  endif.

  if i > ld_v__lines. "calc
    e_f__continue = gd_s__rules-f_continue.
    return.
  else.

    if f_found = abap_true.
      read table gd_s__rules-assign index i
           assigning <ld_s__assign>.
    else.
      read table gd_s__rules-assign_not_found index i
           assigning <ld_s__assign>.
    endif.

    ld_v__i = i + 1.

    try.
      try.
          loop at <ld_s__assign>-function assigning <ld_s__function>.
            call method zcl_bdnl_assign_function=>(<ld_s__function>-func_name)
              parameter-table
                <ld_s__function>-bindparam.
          endloop.
        catch cx_root into lr_x__root. "#EC CATCH_ALL
          raise exception type zcx_bdnl_work_func
                 exporting name      =  <ld_s__function>-func_name
                           bindparam = <ld_s__function>-bindparam
                           previous  = lr_x__root.
        endtry.

        loop at <ld_s__assign>-check reference into gr_t__check.
          clear gd_v__check_index.
          if check_expr( abap_false ) = abap_false.
            raise exception type zcx_bdnl_skip_assign.
          endif.
        endloop.

        <ld_s__assign>-object->rule_assign_1( <ld_s__assign>-class ).
        catch zcx_bdnl_skip_assign.
          zcl_bdnl_container=>add_skip( ).
        endtry.

        e_f__continue = assign( i = ld_v__i f_found = f_found ).
      endif.

    endmethod.

method check_prim.

  field-symbols
  : <ld_s__check> type zbnlt_s__check_exp
  , <ld_v__data>  type c
  , <ld_t__check> type zbnlt_s__check
  .

  check get = abap_true.

  assign gr_t__check->* to <ld_t__check>.


  add 1 to gd_v__check_index.
  read table <ld_t__check>-exp index gd_v__check_index
       assigning <ld_s__check>.

  if sy-subrc = 0.

    if <ld_s__check>-data is bound.
      assign <ld_s__check>-data->* to <ld_v__data>.
      return = <ld_v__data>.
    else.
      case <ld_s__check>-operator.
        when zblnc_keyword-not.
          if check_prim( get ) = abap_true.
            return = abap_false.
          else.
            return = abap_true.
          endif.
        when zblnc_keyword-open_parenthesis.
          return = check_expr( abap_true ).
        when others.
          return = <ld_s__check>-operator.
      endcase.
    endif.
  endif.


endmethod.

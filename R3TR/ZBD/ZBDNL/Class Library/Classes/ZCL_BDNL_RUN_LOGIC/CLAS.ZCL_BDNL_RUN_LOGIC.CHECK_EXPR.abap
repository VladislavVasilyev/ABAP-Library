method check_expr.

  field-symbols
  : <ld_s__log_exp> type zbnlt_s__log_exp
  , <ld_v__left>    type any
  , <ld_v__right>   type any
  , <ld_t__range>   type standard table
  , <ld_v__result>  type c
  , <ld_t__check>   type zbnlt_s__check
  .

  if get = abap_false.
    assign gr_t__check->* to <ld_t__check>.

    loop at  <ld_t__check>-log_exp assigning <ld_s__log_exp>.
      assign
      : <ld_s__log_exp>-left->*   to <ld_v__left>
      , <ld_s__log_exp>-right->*  to <ld_v__right>
      , <ld_s__log_exp>-result->* to <ld_v__result>
      .

      <ld_v__result> = abap_false.
      case <ld_s__log_exp>-log_exp.
        when zblnc_keyword-eq.
          check <ld_v__left> eq <ld_v__right>.
          <ld_v__result> = abap_true.
        when zblnc_keyword-ne.
          check <ld_v__left> ne <ld_v__right>.
          <ld_v__result> = abap_true.
        when zblnc_keyword-lt.
          check <ld_v__left> lt <ld_v__right>.
          <ld_v__result> = abap_true.
        when zblnc_keyword-gt.
          check <ld_v__left> gt <ld_v__right>.
          <ld_v__result> = abap_true.
        when zblnc_keyword-le.
          check <ld_v__left> le <ld_v__right>.
          <ld_v__result> = abap_true.
        when zblnc_keyword-ge.
          check <ld_v__left> ge <ld_v__right>.
          <ld_v__result> = abap_true.
        when zblnc_keyword-ii.
          check <ld_v__left> is initial.
          <ld_v__result> = abap_true.
        when zblnc_keyword-ni.
          check <ld_v__left> is not initial.
          <ld_v__result> = abap_true.
        when zblnc_keyword-in.
          assign <ld_s__log_exp>-right->* to <ld_t__range>.
          check <ld_v__left> in <ld_t__range>.
          <ld_v__result> = abap_true.
      endcase.
    endloop.
  endif.

  return = check_prim( abap_true ).

  do.
    case  check_prim( abap_true ).
      when zblnc_keyword-and.
        if return = abap_true and check_prim( abap_true ) = abap_true.
          return = abap_true.
        else.
          return = abap_false.
        endif.
        continue.
      when zblnc_keyword-or.
        if return = abap_true or check_prim( abap_true ) = abap_true.
          return = abap_true.
        else.
          return = abap_false.
        endif.
        continue.
      when zblnc_keyword-not.
        case check_prim( abap_true ).
          when abap_true.
            return = abap_false.
          when abap_false.
            return = abap_true.
        endcase.
      when others.
        return.
    endcase.
  enddo.

endmethod.

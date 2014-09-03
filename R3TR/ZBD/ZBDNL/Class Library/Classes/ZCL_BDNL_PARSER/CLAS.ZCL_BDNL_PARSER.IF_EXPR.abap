method if_expr.

  data
  : ld_s__token         type string
  , ld_v__token_o       type string
  .

  field-symbols
  : <ld_s__check>       type zbnlt_s__stack_check
  .

  return = if_term( abap_true ).

  do .
    case if_term( abap_false ).
      when zblnc_keyword-and.
        return = return * if_term( abap_true ).
        if return > 0.
          return = true.
        else.
          return = false.
        endif.
        continue.
      when zblnc_keyword-or.
        return  = return + if_term( abap_true ).
        if return > 0.
          return = true.
        else.
          return = false.
        endif.
        continue.
      when zblnc_keyword-dot.
        gr_o__cursor->get_token( esc = abap_true ).
        return.
      when  others.
        "error
        return.
    endcase.
  enddo.

endmethod.

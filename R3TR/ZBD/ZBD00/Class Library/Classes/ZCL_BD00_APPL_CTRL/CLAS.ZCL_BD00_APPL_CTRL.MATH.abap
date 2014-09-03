method math.
  field-symbols
   : <operand> type any
   , <result>   type any
   .

  assign gr_o__line->line->(gr_o__model->gd_v__signeddata) to <result>.

  if signeddata is supplied.
    assign signeddata to <operand>.
  elseif operand is supplied .
    assign operand->gr_o__line->line->(operand->gr_o__model->gd_v__signeddata) to <operand>.
  endif.

  case operation.
    when cs_add. add      <operand> to   <result>.
    when cs_sub. subtract <operand> from <result>.
    when cs_mul. multiply <result>  by   <operand>.
    when cs_div. divide   <result>  by   <operand>.
  endcase.
endmethod.

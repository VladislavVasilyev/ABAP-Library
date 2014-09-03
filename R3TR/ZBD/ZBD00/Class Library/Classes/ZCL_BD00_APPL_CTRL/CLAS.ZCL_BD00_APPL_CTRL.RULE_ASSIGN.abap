method rule_assign.
  data
  : ld_s__class_reg     like line of gd_t__class_reg
  .

  if gd_s__last_rule-id ne id.
    read table gd_t__class_reg
         with table key id = id
         into  gd_s__last_rule.
  endif.

  gd_s__last_rule-class->rule(  ).

endmethod.

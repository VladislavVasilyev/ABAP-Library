method get_rule_class.
  data
  :  ld_s__last_rule type ty_s_class_reg
  .

  read table gd_t__class_reg
     with table key id = id
     into  ld_s__last_rule.

  class ?= ld_s__last_rule-class.

endmethod.

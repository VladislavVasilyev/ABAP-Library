*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE set_attr_ns>.
  call method &1->set_attribute_ns
    exporting
      name   = &3
      prefix = &2
      value  = &4.
END-OF-DEFINITION.
DEFINE set_simp_el>.
  &1 = gd_i__document->create_simple_element(
            name = &2
            value  = &3
            parent = &4 ).
END-OF-DEFINITION.

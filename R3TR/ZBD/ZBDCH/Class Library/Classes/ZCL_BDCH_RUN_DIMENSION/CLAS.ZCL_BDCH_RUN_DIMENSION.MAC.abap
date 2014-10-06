*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
define mprint>.

    message &1 type 'S'.

end-of-definition.

define pprint>.

    concatenate &1 ` = ` &2 into ld_v__string.
    message ld_v__string type 'S'.

end-of-definition.

define st>.

  case &1.
    when abap_true.
      &2 = `ON`.
    when others.
      &2 = `OFF`.
  endcase.

end-of-definition.

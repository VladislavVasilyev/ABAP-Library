*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE print>.

    cl_ujk_logger=>log( &1 ).
    message &1 type 'S'.

END-OF-DEFINITION.

DEFINE mprint>.

    message &1 type 'S'.

END-OF-DEFINITION.

DEFINE pprint>.

    concatenate &1 ` = ` &2 into ld_v__string.
    message ld_v__string type 'S'.

END-OF-DEFINITION.


DEFINE st>.
  case &1.
    when abap_true.
      &2 = `ON`.
    when others.
      &2 = `OFF`.
  endcase.
END-OF-DEFINITION.

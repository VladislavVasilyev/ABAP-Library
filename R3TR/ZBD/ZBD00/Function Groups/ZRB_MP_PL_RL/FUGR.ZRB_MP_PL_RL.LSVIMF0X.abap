*&--------------------------------------------------------------------*
*&      Form VIM_SET_GLOBAL_FIELD_VALUE                               *
*&--------------------------------------------------------------------*
* set global field value (for external call)                          *
*&--------------------------------------------------------------------*
FORM VIM_SET_GLOBAL_FIELD_VALUE USING VALUE(NAME_OF_FIELD_TO_SET) TYPE C
                                      VALUE(TYPE_OF_FIELD_TO_SET) TYPE C
                                      VALUE(VALUE_TO_SET)
                                      VSGFV_RETURN LIKE SY-SUBRC.

  FIELD-SYMBOLS: <FIELD>.
  ASSIGN (NAME_OF_FIELD_TO_SET) TO <FIELD> TYPE TYPE_OF_FIELD_TO_SET.
  IF SY-SUBRC EQ 0.
    <FIELD> = VALUE_TO_SET.
  ENDIF.
  VSGFV_RETURN = SY-SUBRC.
ENDFORM.                               "vim_set_global_field_value

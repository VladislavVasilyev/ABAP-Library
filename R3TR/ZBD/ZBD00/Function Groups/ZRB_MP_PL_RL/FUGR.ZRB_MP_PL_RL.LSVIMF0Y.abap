*&--------------------------------------------------------------------*
*&      Form VIM_GET_GLOBAL_FIELD_VALUE                               *
*&--------------------------------------------------------------------*
* get global field value (for external call)                          *
*&--------------------------------------------------------------------*
FORM vim_get_global_field_value USING value(name_of_field_to_get) TYPE c
                                      value(type_of_field_to_get) TYPE c
                                      field_value
                                      vggfv_return LIKE sy-subrc.

  FIELD-SYMBOLS: <field> TYPE ANY.
  ASSIGN (name_of_field_to_get) TO <field>
   CASTING TYPE (type_of_field_to_get).
  IF sy-subrc EQ 0.
    field_value = <field>.
  ENDIF.
  vggfv_return = sy-subrc.
ENDFORM.                               "vim_get_global_field_value

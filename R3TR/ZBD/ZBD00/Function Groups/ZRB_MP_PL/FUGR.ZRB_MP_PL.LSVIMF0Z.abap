*&--------------------------------------------------------------------*
*&      Form VIM_GET_GLOBAL_TABLE                                     *
*&--------------------------------------------------------------------*
* get global field table (for external call)                          *
*&--------------------------------------------------------------------*
FORM vim_get_global_table USING value(name_of_table_to_get) TYPE c
                                table_out TYPE ANY TABLE
                                vggt_return LIKE sy-subrc.

  FIELD-SYMBOLS: <table> TYPE ANY TABLE.
  ASSIGN (name_of_table_to_get) TO <table>.
  IF sy-subrc EQ 0.                                         "#EC *
    table_out = <table>.
  ENDIF.
  vggt_return = sy-subrc.
ENDFORM.                               "vim_get_global_field_value

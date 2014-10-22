*&--------------------------------------------------------------------*
*&      Form VIM_CONVERT_TABKEY                                       *
*&--------------------------------------------------------------------*
* ...                                                                 *
*&--------------------------------------------------------------------*
FORM vim_convert_tabkey USING value(vct_key_int) TYPE x
                                    vct_key_ext TYPE vim_tabkey_c
                                    vct_xkeylen TYPE i.
  FIELD-SYMBOLS: <h1>, <h2>.
  CLEAR vct_xkeylen.
  <f1_wax> = vct_key_int.
  LOOP AT x_namtab WHERE keyflag NE space AND texttabfld EQ space.
    CHECK x_namtab-position LT x_header-keylen.
*    ASSIGN: vct_key_int+x_namtab-position(x_namtab-flength) TO <h1>,
*            vct_key_ext+vct_xkeylen(x_namtab-outputlen) TO <h2>.
    ASSIGN: COMPONENT x_namtab-viewfield OF STRUCTURE <table1_wa>
             TO <h1>,
            vct_key_ext+vct_xkeylen(x_namtab-outputlen) TO <h2>.
    IF ( x_namtab-inttype NE 'C' AND x_namtab-inttype NE 'N' )"SW
       OR x_namtab-convexit NE space.
      CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
           EXPORTING
                value_intern = <h1>
                tabname      = x_header-maintview
                fieldname    = x_namtab-viewfield
*                inttype      = x_namtab-inttype
*                datatype     = x_namtab-datatype
*                decimals     = x_namtab-decimals
*                convexit     = x_namtab-convexit
*                sign         = x_namtab-sign
                outputlen    = x_namtab-outputlen
                intlen       = x_namtab-flength
           IMPORTING
                value_extern = <h2>.
    ELSE.
      <h2> = <h1>.
    ENDIF.
    ADD x_namtab-outputlen TO vct_xkeylen.
  ENDLOOP.
ENDFORM.                               "vim_convert_tabkey

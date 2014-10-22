*&--------------------------------------------------------------------*
*&      Form BUILD_VALTAB_HFIELDS                                     *
*&--------------------------------------------------------------------*
* build value tab ignoring hidden fields using structure table        *
*&--------------------------------------------------------------------*
FORM build_valtab_hfields.

  DATA: fieldname TYPE fnam_____4.
  FIELD-SYMBOLS: <value> TYPE ANY, <valfld> TYPE ANY,
                 <value_tab> TYPE x.
  CLEAR value_tab.
  ASSIGN value_tab TO <value_tab> CASTING.
  LOOP AT structure_table.
    IF x_header-bastab NE space AND x_header-texttbexst NE space AND
       structure_table-tabname EQ x_header-texttab.
* texttabfield
      ASSIGN COMPONENT structure_table-fieldname
       OF STRUCTURE <vim_ext_txt_struc> TO <value>.
*     READ TABLE x_namtab WITH KEY viewfield = structure_table-fieldname
*                                        texttabfld = 'X'.
    ELSE.
* viewfield
      LOOP AT x_namtab WHERE viewfield = structure_table-fieldname AND
                        ( texttabfld = space OR keyflag = space ).
        ASSIGN COMPONENT structure_table-fieldname
         OF STRUCTURE <vim_extract_struc> TO <value>.
        EXIT.
      ENDLOOP.
    ENDIF.
    CHECK <value> IS ASSIGNED.
    CONCATENATE structure_table-tabname structure_table-fieldname
     INTO fieldname SEPARATED BY '-'.
    ASSIGN <value_tab>+structure_table-offset(structure_table-intlen)
     TO <valfld> CASTING TYPE (fieldname).
    MOVE <value> TO <valfld>.
*    CHECK sy-subrc EQ 0.
*    MOVE extract+x_namtab-position(x_namtab-flength)
*     TO value_tab+structure_table-offset(structure_table-intlen).
  ENDLOOP.
  APPEND value_tab.
ENDFORM.                               "build_valtab_hfields

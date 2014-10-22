*&--------------------------------------------------------------------*
*&      Form VIM_RESTORE_SUBSET_CONDS                                 *
*&--------------------------------------------------------------------*
* restore subset conditions                                           *
*&--------------------------------------------------------------------*
FORM vim_restore_subset_conds.
  DATA: hi TYPE i.
  FIELD-SYMBOLS: <ifield> TYPE ANY.
  LOOP AT dpl_sellist WHERE ddic CO vim_subset_marks.
    hi = sy-tabix.
    READ TABLE x_namtab INDEX dpl_sellist-tabix.
    ASSIGN COMPONENT x_namtab-viewfield
     OF STRUCTURE <vim_extract_struc> TO <ifield>.
*    ASSIGN EXTRACT+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH) TO <IFIELD>.
    CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
         EXPORTING
              value_intern = <ifield>
              tabname      = x_header-maintview
              fieldname    = x_namtab-viewfield
              outputlen    = x_namtab-outputlen
              intlen       = x_namtab-flength
         IMPORTING
              value_extern = dpl_sellist-value.
    CLEAR dpl_sellist-converted.
    IF dpl_sellist-value IS INITIAL. dpl_sellist-initial = 'X'. ENDIF.
    MODIFY dpl_sellist INDEX hi.
  ENDLOOP.
  dba_sellist[] = dpl_sellist[].
ENDFORM.

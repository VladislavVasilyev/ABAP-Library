*---------------------------------------------------------------------*
*       FORM MARKIERE_ALLE                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ACTION                                                        *
*---------------------------------------------------------------------*
FORM MARKIERE_ALLE USING ACTION.
  CHECK MAXLINES NE 0.
  LOOP AT EXTRACT.
    CHECK <XACT> NE LEER.
    CHECK <XMARK> NE ACTION.
    READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH."#EC *
    <XMARK> = ACTION.
    <MARK>  = ACTION.
    MODIFY TOTAL INDEX SY-TABIX.
    MODIFY EXTRACT.
    IF ACTION EQ MARKIERT.
      ADD: 1 TO MARK_EXTRACT,
           1 TO MARK_TOTAL.
    ELSE.
      SUBTRACT: 1 FROM MARK_EXTRACT,
                1 FROM MARK_TOTAL.
      CLEAR BLOCK_SW.
    ENDIF.
  ENDLOOP.
ENDFORM.

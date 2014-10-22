*---------------------------------------------------------------------*
*       FORM MARKIERE                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I                                                             *
*---------------------------------------------------------------------*
FORM MARKIERE USING I.
  READ TABLE EXTRACT INDEX I.
  READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH."#EC *
  IF <XMARK> EQ MARKIERT.
    <XMARK> = NICHT_MARKIERT.
    <MARK>  = NICHT_MARKIERT.
    MARK_EXTRACT = MARK_EXTRACT - 1.
    MARK_TOTAL  = MARK_TOTAL  - 1.
  ELSE.
    <XMARK> = MARKIERT.
    <MARK>  = MARKIERT.
    MARK_EXTRACT = MARK_EXTRACT + 1.
    MARK_TOTAL  = MARK_TOTAL  + 1.
  ENDIF.
  MODIFY TOTAL INDEX SY-TABIX.
  MODIFY EXTRACT INDEX I.
ENDFORM.

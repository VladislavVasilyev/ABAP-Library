*---------------------------------------------------------------------*
*       FORM MARKIERE_BLOCK                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM MARKIERE_BLOCK.
  INDEX = FIRSTLINE + L - 1.
  IF L EQ 0 OR INDEX GT MAXLINES.
    MESSAGE S032(SV).
    EXIT.
  ENDIF.
  PERFORM MARKIERE USING INDEX.
  IF BLOCK_SW EQ MARKIERT.
    BLOCK_2 = INDEX.
    BLOCK_SW = NICHT_MARKIERT.
  ELSE.
    BLOCK_1 = INDEX.
    BLOCK_SW = MARKIERT.
    MESSAGE S066(SV).                  "Bitte Blockende markieren
    EXIT.
  ENDIF.
  COUNTER = 0.
  LOOP AT EXTRACT.
    COUNTER = COUNTER + 1.
    IF BLOCK_1 LE BLOCK_2.
      CHECK COUNTER BETWEEN BLOCK_1 AND BLOCK_2.
    ELSE.
      CHECK COUNTER BETWEEN BLOCK_2 AND BLOCK_1.
    ENDIF.
    READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH."#EC *
    IF <XMARK> NE MARKIERT.
      MARK_EXTRACT = MARK_EXTRACT + 1.
      MARK_TOTAL  = MARK_TOTAL  + 1.
    ENDIF.
    <XMARK> = MARKIERT.
    <MARK>  = MARKIERT.
    MODIFY TOTAL INDEX SY-TABIX.
    MODIFY EXTRACT.
  ENDLOOP.
ENDFORM.

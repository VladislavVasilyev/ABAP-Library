*&--------------------------------------------------------------------*
*&      Form  MARK_IGNORED_ENTRIES                                    *
*&--------------------------------------------------------------------*
* Wiederherstellen der Markierungen für 'übergangene' Einträge        *
*---------------------------------------------------------------------*
FORM MARK_IGNORED_ENTRIES CHANGING MIE_NUMBER.
  DATA: TRANSLATION_MASK(2) TYPE C, H_IX LIKE SY-TABIX.

  CHECK IGNORED_ENTRIES_EXIST NE SPACE.
  MOVE: UEBERGEHEN TO TRANSLATION_MASK,
        MARKIERT   TO TRANSLATION_MASK+1(1).
  IF STATUS-MODE EQ LIST_BILD.
    CLEAR MIE_NUMBER.
    LOOP AT TOTAL.
      CHECK <MARK> EQ UEBERGEHEN.
      ADD 1 TO MIE_NUMBER.
      READ TABLE EXTRACT WITH KEY <vim_xTOTAL_key> BINARY SEARCH."#EC *
      IF SY-SUBRC EQ 0.
        TRANSLATE <XMARK> USING TRANSLATION_MASK.
        MODIFY EXTRACT INDEX SY-TABIX.
      ENDIF.
      TRANSLATE <MARK> USING TRANSLATION_MASK.
      MODIFY TOTAL.
    ENDLOOP.
  ELSE.
    MOVE DETA_MARK_SAFE TO TRANSLATION_MASK+1(1).
    READ TABLE EXTRACT INDEX NEXTLINE.
    CHECK sy-subrc = 0.                          "UF HW 490645
    MOVE SY-TABIX TO H_IX.
    READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH."#EC *
    TRANSLATE <MARK> USING TRANSLATION_MASK.
    MODIFY TOTAL INDEX SY-TABIX.
    TRANSLATE <XMARK> USING TRANSLATION_MASK.
    MODIFY EXTRACT INDEX H_IX.
    MIE_NUMBER = 1.
  ENDIF.
  IF mie_number > 0.
    CLEAR IGNORED_ENTRIES_EXIST.
  ENDIF.
ENDFORM.                               " MARK_IGNORED_ENTRIES

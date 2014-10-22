*---------------------------------------------------------------------*
*       FORM LISTE_ADDRESS_MAINTAIN                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM LISTE_ADDRESS_MAINTAIN.
  IF X_HEADER-ADRNBRFLAG EQ SPACE.
    MESSAGE E001(SV).
    EXIT.
  ENDIF.
  LOOP AT EXTRACT.
    CHECK <XMARK> EQ MARKIERT.
    MOVE SY-TABIX TO EXIND.
    PERFORM MOVE_EXTRACT_TO_VIEW_WA.
    PERFORM ADDRESS_MAINTAIN.
    PERFORM UPDATE_TAB.
  ENDLOOP.
ENDFORM.

*&--------------------------------------------------------------------*
*&      Form  TEMP_DELIM_DETERMINE_ACTION                             *
*&--------------------------------------------------------------------*
* determine action flag                                               *
*&--------------------------------------------------------------------*
FORM TEMP_DELIM_DETERMINE_ACTION USING VALUE(TDDA_INDEX) TDDA_ACT
                                                         TDDA_ACT_TXT.
  LOCAL: TOTAL.
  READ TABLE TOTAL INDEX TDDA_INDEX.
  IF <ACTION> EQ NEUER_GELOESCHT.
    TDDA_ACT = NEUER_EINTRAG.
  ELSE.
    TDDA_ACT = AENDERN.
  ENDIF.
  IF X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE.
    IF <ACTION_TEXT> EQ NEUER_GELOESCHT.
      TDDA_ACT_TXT = NEUER_EINTRAG.
    ELSE.
      TDDA_ACT_TXT = AENDERN.
    ENDIF.
  ENDIF.
ENDFORM.                               "temp_delim_determine_action

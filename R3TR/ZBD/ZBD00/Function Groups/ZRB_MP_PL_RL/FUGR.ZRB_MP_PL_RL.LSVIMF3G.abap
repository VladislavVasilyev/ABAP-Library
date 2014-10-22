*---------------------------------------------------------------------*
*       FORM LISTE_MARKIERE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM LISTE_MARKIERE.
  INDEX = FIRSTLINE + L - 1.
  IF L EQ 0 OR INDEX GT MAXLINES.
    MESSAGE S032(SV).
    EXIT.
  ENDIF.
  PERFORM MARKIERE USING INDEX.
ENDFORM.

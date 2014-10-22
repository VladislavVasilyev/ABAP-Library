*---------------------------------------------------------------------*
*       FORM IGNORIEREN                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM IGNORIEREN. "wird nur noch auf Detailbild prozessiert
  <STATUS>-UPD_FLAG = SPACE.
  IF STATUS-ACTION EQ KOPIEREN OR VIM_SPECIAL_MODE EQ VIM_DELETE.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
* IF MAXLINES LE 1.
*   STATUS-ACTION = AENDERN.
*   TITLE-ACTION  = AENDERN.
*   PERFORM FILL_EXTRACT.
* ELSE.
*   SORT EXTRACT.
* ENDIF.
  NEUER = 'N'.
  IF REPLACE_MODE EQ SPACE.
    CLEAR FUNCTION.
*   IF STATUS-MODE EQ DETAIL_BILD.
*     FUNCTION = 'DETA'.
*     SET SCREEN DETAIL.
    IF STATUS-ACTION EQ HINZUFUEGEN.
      FUNCTION = 'NEWL'.
      PERFORM HINZUFUEGEN.
    ELSE.
      SET SCREEN LISTE.
      LEAVE SCREEN.
    ENDIF.
*   ELSE.
*     NEXTLINE = 1.
*     SET SCREEN LISTE.
*   ENDIF.
  ELSE.
    CLEAR VIM_ACT_DYNP_VIEW. SET SCREEN 0. LEAVE SCREEN.
  ENDIF.
ENDFORM.

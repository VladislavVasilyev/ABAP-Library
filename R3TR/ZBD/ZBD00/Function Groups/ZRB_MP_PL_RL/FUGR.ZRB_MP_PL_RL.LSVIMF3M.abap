*---------------------------------------------------------------------*
*       FORM LISTE_ABBRECHEN                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM LISTE_ABBRECHEN.
* CHECK REPLACE_MODE EQ SPACE.
*(DEL)  IF STATUS-ACTION EQ ANZEIGEN.
*(DEL)    MESSAGE I001(SV).
*(DEL)    EXIT.
*(DEL)  ENDIF.
  IF SY-DATAR NE SPACE.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
              TITEL          = SVIM_TEXT_005
              TEXTLINE1      = SVIM_TEXT_009
              TEXTLINE2      = SVIM_TEXT_006
              DEFAULTOPTION  = 'N'
              CANCEL_DISPLAY = ' '
         IMPORTING
              ANSWER         = ANSWER.
    IF ANSWER EQ 'J'.
      NEUER = 'N'.
      IF STATUS-ACTION EQ KOPIEREN.
        SET SCREEN 0.
      ELSE.
        SET SCREEN LISTE.
        NEXTLINE = FIRSTLINE.
      ENDIF.
      CLEAR <STATUS>-UPD_FLAG.
      LEAVE SCREEN.
    ELSE.
      CLEAR FUNCTION.
    ENDIF.
  ELSE.
    IF VIM_SINGLE_ENTRY_FUNCTION NE SPACE.
      TRANSLATE STATUS-ACTION USING 'AU'. STATUS-MODE = GESAMTDATEN.
    ENDIF.
    CASE STATUS-ACTION.
      WHEN HINZUFUEGEN. PERFORM LISTE_BACK.
      WHEN KOPIEREN.    SET SCREEN 0.
      WHEN OTHERS.
        FUNCTION = 'BACK'. SET SCREEN 0. CLEAR VIM_ACT_DYNP_VIEW.
        PERFORM UPDATE_STATUS.
    ENDCASE.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.

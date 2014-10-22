*---------------------------------------------------------------------*
*       FORM TRANSPORTIEREN                                           *
*---------------------------------------------------------------------*
*       send popup to confirm: saving etc.                            *
*---------------------------------------------------------------------*
FORM TRANSPORTIEREN.
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
       EXPORTING
            TITEL         = SVIM_TEXT_020  "Einträge transportieren
            DIAGNOSETEXT1 = SVIM_TEXT_018  "Daten wurden verändert.
            DIAGNOSETEXT2 =
               SVIM_TEXT_021           "Wenn die Änderungen transport
            DIAGNOSETEXT3 =
               SVIM_TEXT_022           "werden sollen, müssen sie ers
            TEXTLINE1     = SVIM_TEXT_023  "gesichert werden.
            TEXTLINE2     = SVIM_TEXT_019  "Änderungen vorher sichern ?
       IMPORTING
            ANSWER        = ANSWER.
  CASE ANSWER.
    WHEN 'J'.
      SY-SUBRC = 0.
    WHEN 'N'.
      CLEAR <STATUS>-UPD_FLAG.
      SY-SUBRC = 8.
    WHEN 'A'.
      SY-SUBRC = 12.
  ENDCASE.
ENDFORM.

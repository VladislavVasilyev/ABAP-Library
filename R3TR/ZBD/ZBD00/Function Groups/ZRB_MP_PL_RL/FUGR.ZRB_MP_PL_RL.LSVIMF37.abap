*---------------------------------------------------------------------*
*       FORM FILL_EXTRACT                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM FILL_EXTRACT.
  DATA: REC LIKE SY-SUBRC VALUE 9, TOTAL_SAFE(4096) TYPE C, INDEI TYPE I, "#EC NEEDED
                    HF TYPE I VALUE 1.                                    "#EC NEEDED
  FIELD-SYMBOLS: <BEGDATE_MASK>.
  REFRESH: EXTRACT. CLEAR EXTRACT.
  CLEAR VIM_MAINKEY.
  TRANSLATE VIM_NO_MAINKEY_EXISTS USING VIM_NO_MKEY_NOT_PROCSD_PATT.
  IF X_HEADER-DELMDTFLAG NE SPACE.
    ASSIGN <VIM_NEW_BEGDATE> TO <BEGDATE_MASK> TYPE 'C'.
  ENDIF.
  LOOP AT TOTAL.
    PERFORM NORMAL_SELECT.
    CHECK SY-SUBRC EQ 0.
    IF X_HEADER-DELMDTFLAG NE SPACE AND
       VIM_IGNORE_COLLAPSED_MAINKEYS EQ SPACE.
      PERFORM CHECK_AND_MODIFY_MAINKEY_TAB USING REC.
      IF REC NE 0.
        VIM_COLL_MAINKEYS_BEG_IX = VIM_LAST_COLL_MAINKEYS_IX.
      ENDIF.
      CHECK REC LT 8.
      IF REC EQ 4. REC = 9. ENDIF.
    ENDIF.
    EXTRACT = TOTAL.
    APPEND EXTRACT.
  ENDLOOP.
  VIM_COLL_MAINKEYS_BEG_IX = 1.
  IF REC NE 9 AND REC NE 0.
    PERFORM MOD_EXTRACT_AND_MAINKEY_TAB USING 'A' 0.
  ENDIF.
  DESCRIBE TABLE EXTRACT LINES MAXLINES.
  MARK_EXTRACT = MARK_TOTAL.
  STATUS-DATA = GESAMTDATEN.
  TITLE-DATA  = GESAMTDATEN.
  CLEAR <STATUS>-SELECTED.
* <STATUS>-DISPL_MODE = EXPANDED. "default display mode
  IF MAXLINES EQ 0.
    PERFORM VIM_SEND_SV005_OR_SV766 USING '766'
                                          'RESET'.
    IF FUNCTION NE 'DELE' AND FUNCTION NE 'SAVE'.           "HWR
      IF X_HEADER-SELECTION EQ SPACE AND FILL_EXTR_FIRST_PROC EQ SPACE.
        IF NOT VIM_OC_INST IS INITIAL
* data access restricted?
          AND ( ( <STATUS>-ST_ACTION = AENDERN
                AND NOT VIM_OC_INST->OC_SELCRIT_MAINT_TAB IS INITIAL )
          OR ( 'ST' CS <STATUS>-ST_ACTION
                AND NOT VIM_OC_INST->OC_SELCRIT_READ_TAB IS INITIAL ) ).
          MESSAGE S766(SV).
*   Eingeschränkte Anzeige von Datensätzen.
        ELSE.
          MESSAGE S065(SV).            "keine Einträge vorhanden
        ENDIF.
        MOVE 'X' TO FILL_EXTR_FIRST_PROC.
      ELSE.
        CLEAR <TABLE1>.                                     "GKPR/1045371
        MESSAGE S004(SV). "keine Einträge gemäß Selektion gefunden
      ENDIF.
    ENDIF.                                                  "HWR
    EXIT.
*  ELSEIF maxlines EQ 1.
  ELSEIF MAXLINES EQ 1 AND FUNCTION NE 'CMPR'.              "822766
    PERFORM VIM_MAINTAIN_SINGLE_SET.    "UFint2329966/2000
  ELSEIF NOT VIM_OC_INST IS INITIAL AND
   FUNCTION NE 'DELE' AND FUNCTION NE 'SAVE'.
* data access restricted?
    IF ( <STATUS>-ST_ACTION = AENDERN
         AND NOT VIM_OC_INST->OC_SELCRIT_MAINT_TAB IS INITIAL )
     OR ( 'ST' CS <STATUS>-ST_ACTION
          AND NOT VIM_OC_INST->OC_SELCRIT_READ_TAB IS INITIAL ).
      PERFORM VIM_SEND_SV005_OR_SV766 USING '766'
                                          'SENDIT'.
*   Eingeschränkte Anzeige von Datensätzen.
    ENDIF.
  ELSE.
    PERFORM VIM_SEND_SV005_OR_SV766 USING '766'
                                          'RESET'.
  ENDIF.
ENDFORM.                    "fill_extract

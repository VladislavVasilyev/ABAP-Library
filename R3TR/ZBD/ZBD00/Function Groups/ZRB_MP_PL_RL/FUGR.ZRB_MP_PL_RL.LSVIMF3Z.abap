*---------------------------------------------------------------------*
*       FORM INIT_STATE_VECTOR                                        *
*---------------------------------------------------------------------*
* viewspezif. Statusvektor initialisieren                             *
*---------------------------------------------------------------------*
FORM INIT_STATE_VECTOR.
* IF <STATUS>-ALR_SETUP EQ SPACE.
  NEXTLINE = 1.
  MOVE: NICHT_GELOESCHT   TO <STATUS>-ST_DELETE,
        GESAMTDATEN       TO <STATUS>-ST_DATA,
        GESAMTDATEN       TO TITLE-DATA,
        LIST_BILD         TO <STATUS>-ST_MODE,
        LIST_BILD         TO TITLE-MODE,
        MAINT_MODE        TO <STATUS>-ST_ACTION,
        MAINT_MODE        TO TITLE-ACTION,
        <STATUS>-CORR_NBR TO <STATUS>-L_CORR_NBR,
        CORR_NBR          TO <STATUS>-CORR_NBR,
        TITLE             TO <STATUS>-TITLE,
        1                 TO <STATUS>-CUR_LINE,
        1                 TO <STATUS>-FIRSTLINE,
        0                 TO <STATUS>-MK_XT,
        0                 TO <STATUS>-MK_TO,
        0                 TO <STATUS>-MAXLINES,
        0                 TO <STATUS>-CUR_OFFSET,
        SPACE             TO <STATUS>-FCODE,
        SPACE             TO <STATUS>-CUR_FIELD,
        SPACE             TO <STATUS>-UPD_FLAG,
        SPACE             TO <STATUS>-CRCNTSKNWN,
        SPACE             TO <STATUS>-KEYTBMODFD,
        SPACE             TO <STATUS>-DLCLALRCKD,
        SPACE             TO <STATUS>-TR_ALRCHKD,
*         'X'               TO <STATUS>-ALR_SETUP,
        'x'               TO <STATUS>-INITIALIZD,
        NICHT_MARKIERT    TO BLOCK_SW.
  IF MAINT_MODE = STATUS-ACTION OR MAINT_MODE = ANZEIGEN.  "UF profilesb
    CLEAR <STATUS>-PROF_FOUND.
  ENDIF.                               "UF profilese
  CLEAR <STATUS>-NEWADRCNT.
* ENDIF.
  CLEAR FILL_EXTR_FIRST_PROC.
* Übergangslösung Sortierungsproblem Anfang
* CLEAR <STATUS>-ALR_SORTED.
  TRANSLATE <STATUS>-ALR_SORTED USING 'RXX '.
* Übergangslösung Sortierungsproblem Ende
  CLEAR: VIM_OLD_VIEWKEY, VIM_OLD_ST_SELECTED.
  TRANSLATE VIM_NO_MAINKEY_EXISTS USING VIM_NO_MKEY_NOT_PROCSD_PATT.
  LAST_CORR_NUMBER = <STATUS>-L_CORR_NBR.
ENDFORM.

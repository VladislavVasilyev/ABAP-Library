*---------------------------------------------------------------------*
*       FORM UPDATE_STATUS                                            *
*---------------------------------------------------------------------*
FORM UPDATE_STATUS.
  MOVE: STATUS-DATA TO <STATUS>-ST_DATA,
        STATUS-MODE TO <STATUS>-ST_MODE,
        STATUS-DELETE TO <STATUS>-ST_DELETE,
        STATUS-ACTION TO <STATUS>-ST_ACTION,
        TITLE         TO <STATUS>-TITLE,
*       L             TO <STATUS>-CUR_LINE,
        FIRSTLINE     TO <STATUS>-FIRSTLINE,
        MAXLINES      TO <STATUS>-MAXLINES,
        F             TO <STATUS>-CUR_FIELD,
        O             TO <STATUS>-CUR_OFFSET,
        MARK_EXTRACT  TO <STATUS>-MK_XT,
        MARK_TOTAL    TO <STATUS>-MK_TO,
        FUNCTION      TO <STATUS>-FCODE.
  IF L EQ 0.
    MOVE 1 TO <STATUS>-CUR_LINE.
  ELSE.
    MOVE L TO <STATUS>-CUR_LINE.
  ENDIF.
ENDFORM.                               "UPDATE_STATUS

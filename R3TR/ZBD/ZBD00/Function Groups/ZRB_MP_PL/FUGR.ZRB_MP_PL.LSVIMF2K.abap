*---------------------------------------------------------------------*
*       FORM VIM_STORE_STATE_INFO                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_STORE_STATE_INFO.
  MOVE: STATUS-DATA TO <STATUS>-ST_DATA,
        STATUS-MODE TO <STATUS>-ST_MODE,
        STATUS-DELETE TO <STATUS>-ST_DELETE,
        STATUS-ACTION TO <STATUS>-ST_ACTION,
        TITLE         TO <STATUS>-TITLE,
        MAXLINES      TO <STATUS>-MAXLINES,
        F             TO <STATUS>-CUR_FIELD,
        O             TO <STATUS>-CUR_OFFSET,
        FUNCTION      TO <STATUS>-FCODE.
  IF L EQ 0.
    MOVE 1 TO <STATUS>-CUR_LINE.
  ELSE.
    MOVE L TO <STATUS>-CUR_LINE.
  ENDIF.
ENDFORM.                               "vim_store_state_info

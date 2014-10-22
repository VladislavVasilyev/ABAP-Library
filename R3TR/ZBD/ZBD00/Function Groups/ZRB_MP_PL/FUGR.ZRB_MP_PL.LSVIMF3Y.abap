*---------------------------------------------------------------------*
*       FORM SET_STATUS_NOKEYSELCNDS                                  *
*---------------------------------------------------------------------*
* ........                                                            *
*---------------------------------------------------------------------*
FORM SET_STATUS_NOKEYSELCNDS.
  CLEAR <STATUS>-NOKEYSLCDS.
* LOOP AT DPL_SELLIST.
  LOOP AT <VIM_CK_SELLIST> INTO DPL_SELLIST.
    READ TABLE X_NAMTAB INDEX DPL_SELLIST-TABIX.
    IF X_NAMTAB-KEYFLAG EQ SPACE.
      <STATUS>-NOKEYSLCDS = 'X'. EXIT.
    ENDIF.
  ENDLOOP.
  <STATUS>-INITIALIZD = 'X'.
ENDFORM.                               "set_status_nokeyselcnds

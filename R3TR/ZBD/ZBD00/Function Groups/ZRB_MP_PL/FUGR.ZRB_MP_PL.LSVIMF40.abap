*---------------------------------------------------------------------*
*       FORM SET_NUMBERED_TEXTS                                       *
*---------------------------------------------------------------------*
* numerierte Texte aus Textpool übernehmen                            *
*---------------------------------------------------------------------*
FORM SET_NUMBERED_TEXTS.
  DATA: NAME(20) TYPE C.
  FIELD-SYMBOLS: <M1>.
  READ TEXTPOOL MASTER_FPOOL INTO TEXTPOOL_TAB LANGUAGE SY-LANGU.
  SORT TEXTPOOL_TAB BY ID KEY.
  MOVE NBRD_TEXTS_PREFIX TO NAME.
  LOOP AT TEXTPOOL_TAB WHERE ID EQ 'I'.
    WRITE TEXTPOOL_TAB-KEY TO NAME+NBRD_TEXTS_PREFIX_LENGTH.
    ASSIGN (NAME) TO <M1>.
    IF SY-SUBRC = 0.
      " not all text elements are needed ???
      MOVE TEXTPOOL_TAB-ENTRY TO <M1>.
    ENDIF.
  ENDLOOP.
ENDFORM.

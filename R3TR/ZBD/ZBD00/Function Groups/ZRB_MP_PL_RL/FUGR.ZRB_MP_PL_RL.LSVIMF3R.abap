*---------------------------------------------------------------------*
*       FORM VIM_SAPSCRIPT_FORM_MAINT.                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_SAPSCRIPT_FORM_MAINT.
  LOCAL: STATUS-MODE.
  DATA: VSFM_TABLE LIKE VIMDESC-VIEWNAME, VSFM_FLAG(1) TYPE C,
        VSFM_FIELD LIKE VIMNAMTAB-VIEWFIELD, VSFM_HF TYPE I.

  IF X_HEADER-SCRFRMFLAG EQ SPACE.
    MESSAGE E001(SV).
    EXIT.
  ENDIF.
  IF VIM_NBR_OF_SCRFRM_POINTERS GT 1.
    IF STATUS-MODE EQ DETAIL_BILD. GET CURSOR FIELD F. ENDIF.
    SPLIT F AT '-' INTO VSFM_TABLE VSFM_FIELD.
    IF X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE AND
       VSFM_TABLE EQ X_HEADER-TEXTTAB.
      VSFM_FLAG = 'X'.
    ENDIF.
    READ TABLE X_NAMTAB WITH KEY VIEWFIELD = VSFM_FIELD
                                 TEXTTABFLD = VSFM_FLAG.
    IF X_NAMTAB-DOMNAME NE VIM_SCRFORM_DOMAIN.
      MESSAGE S161(SV). " Bitte stellen Sie den Cursor auf einen Formula
      CLEAR FUNCTION.
      EXIT.
    ENDIF.
*    ASSIGN <TABLE1>+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH)
*                                       TO <VIM_SCRFORM_NAME>.
    ASSIGN component x_namtab-viewfield of structure <TABLE1>
     TO <VIM_SCRFORM_NAME>.
    IF STATUS-MODE EQ LIST_BILD.
      VSFM_HF = FIRSTLINE + L - 1.
      STATUS-MODE = DETAIL_BILD.
    ELSE.
      VSFM_HF = NEXTLINE.
    ENDIF.
    READ TABLE EXTRACT INDEX VSFM_HF.
    PERFORM MOVE_EXTRACT_TO_VIEW_WA.
  ENDIF.
  IF STATUS-MODE EQ LIST_BILD.
    LOOP AT EXTRACT.
      CHECK <XMARK> EQ MARKIERT.
      PERFORM MOVE_EXTRACT_TO_VIEW_WA.
      CALL FUNCTION 'EDIT_FORM'
           EXPORTING
                FORM              = <VIM_SCRFORM_NAME>
*           LANGUAGE          = SY-LANGU
                DISPLAY           = 'X'
*           COMPONENT         = 'HEADER'
           EXCEPTIONS
                UNKNOWN_ACTIVITY  = 1
                UNKNOWN_COMPONENT = 2.
      IF SY-SUBRC NE 0.
        MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO WITH
                SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        CONTINUE.
      ENDIF.
      <XMARK> = NICHT_MARKIERT.
      MODIFY EXTRACT.
      READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH."#EC *
      <MARK> = NICHT_MARKIERT.
      MODIFY TOTAL INDEX SY-TABIX.
      SUBTRACT: 1 FROM MARK_EXTRACT,
                1 FROM MARK_TOTAL.
    ENDLOOP.
  ELSE.                                "detail bild
    CALL FUNCTION 'EDIT_FORM'
         EXPORTING
              FORM              = <VIM_SCRFORM_NAME>
*             LANGUAGE          = SY-LANGU
              DISPLAY           = 'X'
*             COMPONENT         = 'HEADER'
         EXCEPTIONS
              UNKNOWN_ACTIVITY  = 1
              UNKNOWN_COMPONENT = 2.
    IF SY-SUBRC NE 0.
      MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO WITH
              SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      CLEAR FUNCTION. EXIT.
    ENDIF.
    IF <XMARK> EQ MARKIERT.
      <XMARK> = NICHT_MARKIERT.
      MODIFY EXTRACT INDEX NEXTLINE.
      READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH."#EC *
      <MARK> = NICHT_MARKIERT.
      MODIFY TOTAL INDEX SY-TABIX.
      SUBTRACT: 1 FROM MARK_EXTRACT,
                1 FROM MARK_TOTAL.
    ENDIF.
  ENDIF.                               "status-mode eq list_bild
  CLEAR FUNCTION.
ENDFORM.                               "vim_sapscript_form_maint

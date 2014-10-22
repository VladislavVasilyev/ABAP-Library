*&--------------------------------------------------------------------*
*&      Form  PROCESS_ENTRY_RESET                                     *
*&--------------------------------------------------------------------*
* refresh entry from database                                         *
*---------------------------------------------------------------------*
* --> PER_INDEX current index for modifying EXTRACT                   *
*---------------------------------------------------------------------*
FORM PROCESS_ENTRY_RESET USING VALUE(PER_INDEX) TYPE I.
  DATA: PRT_FRKY_SAFE(255) TYPE C, PER_HF TYPE I,
        REFCNT_SAFE TYPE I.

  REFCNT_SAFE = REFCNT.
  PERFORM MOVE_EXTRACT_TO_VIEW_WA.
  IF <XACT> NE ORIGINAL OR             "SW Texttransl
     ( X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE
                                AND <XACT_TEXT> NE ORIGINAL ).

*   check if the <vim_prtfky_wa> is assigned. If the field belong
*   EZN & KEY, the field will be assinged.
    IF vim_prtfky_assigned NE ' '.          "XB 07.2002 BCEK061635
      IF X_HEADER-PTFRKYEXST NE SPACE.
        MOVE <VIM_PRTFKY_WA> TO PRT_FRKY_SAFE.
      ENDIF.
    ENDIF.

    IF X_HEADER-FRM_RP_ORG NE SPACE.
      PERFORM (X_HEADER-FRM_RP_ORG) IN PROGRAM (SY-REPID).
    ELSE.
      IF X_HEADER-BASTAB NE SPACE.
        PERFORM (VIM_TB_READ_SINGLE_FORM) IN PROGRAM (SY-REPID).
      ELSE.
        PER_HF = STRLEN( X_HEADER-MAINTVIEW ).
        IF PER_HF LE 10.
          MOVE X_HEADER-MAINTVIEW TO VIM_READ_SINGLE_FORM-VIEWNAME.
          PERFORM (VIM_READ_SINGLE_FORM) IN PROGRAM.
        ELSE.
          MOVE X_HEADER-MAINTVIEW TO VIM_READ_SINGLE_FORM_40-VIEWNAME.
          PERFORM (VIM_READ_SINGLE_FORM_40) IN PROGRAM.
        ENDIF.
      ENDIF.
    ENDIF.
    IF SY-SUBRC NE 0.
      IF X_HEADER-FRM_RP_ORG EQ SPACE.
        RAISE IMPOSSIBLE_ERROR.        "entry not found
      ENDIF.
    ELSE.

*   check if the <vim_prtfky_wa> is assigned. If the field belong
*   EZN & KEY, the field will be assinged.
      IF vim_prtfky_assigned NE ' '.          "XB 07.2002  BCEK061635
        IF X_HEADER-PTFRKYEXST NE SPACE AND                      "SW
           <VIM_PRTFKY_WA> NE PRT_FRKY_SAFE.
          PERFORM CONSISTENCY_PRT_FRKY_FIELDS USING 'X'.
        ENDIF.
      ENDIF.

      IF X_HEADER-DELMDTFLAG NE SPACE.
        PERFORM TEMPORAL_DELIMITATION.
      ENDIF.
      PERFORM MODIFY_TABLES USING PER_INDEX.
      IF PER_INDEX NE 0.
        ADD 1 TO REFCNT.
      ENDIF.
    ENDIF.

  ENDIF.                               "SW Texttransl ..
  IF X_HEADER-TEXTTBEXST <> SPACE.     "SW Texttransl ..
    IF X_HEADER-FRM_TL_ORG NE SPACE.
      PERFORM (X_HEADER-FRM_TL_ORG) IN PROGRAM (SY-REPID).
    ELSE.
      PERFORM VIM_READ_TEXTTAB_ENTRY.
    ENDIF.
    IF REFCNT_SAFE = REFCNT AND SY-SUBRC = 0.
      ADD 1 TO REFCNT.
      CLEAR <STATUS>-UPD_FLAG.
      IF <XMARK> EQ MARKIERT.
        SUBTRACT: 1 FROM <STATUS>-MK_XT,
                  1 FROM <STATUS>-MK_TO.
        <XMARK> = NICHT_MARKIERT.
        IF PER_INDEX <> 0.
          MODIFY EXTRACT INDEX PER_INDEX.
        ENDIF.
        READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH. "#EC *
        <MARK> = NICHT_MARKIERT.
        MODIFY TOTAL INDEX SY-TABIX.
      ENDIF.
    ENDIF.
  ENDIF.                               ".. Texttransl
ENDFORM.                               "process_entry_reset

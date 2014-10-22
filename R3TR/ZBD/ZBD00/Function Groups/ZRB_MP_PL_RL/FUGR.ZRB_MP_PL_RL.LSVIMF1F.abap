*&--------------------------------------------------------------------*
*&      Form  RESET_ENTRIES                                           *
*&--------------------------------------------------------------------*
* restore the last saved version for the marked entries of EXTRACT    *
*---------------------------------------------------------------------*
* --> RE_MODE requested mode: L - all marked entries, D - single entry*
*---------------------------------------------------------------------*
FORM RESET_ENTRIES USING VALUE(RE_MODE).
  DATA: TEXTTAB_MOD(1) TYPE C.         "SW Texttransl

  VIM_SPECIAL_MODE = VIM_RESET.
  CASE RE_MODE.
    WHEN LIST_BILD.
      MOVE: 0 TO REFCNT, 0 TO NEWCNT, 0 TO ORGCNT.
      LOOP AT EXTRACT.
        CLEAR TEXTTAB_MOD.
        CHECK <XMARK> EQ MARKIERT.
        MOVE SY-TABIX TO INDEX.
        ADD 1 TO NEWCNT.
        CHECK <XACT> NE NEUER_EINTRAG.
        ADD 1 TO ORGCNT.
        IF X_HEADER-TEXTTBEXST <> SPACE.             "SW Texttransl ..
          PERFORM VIM_TEXTTAB_MODIF_FOR_KEY CHANGING TEXTTAB_MOD.
        ENDIF.
        IF X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE.
          CHECK <XACT> NE ORIGINAL OR <XACT_TEXT> NE ORIGINAL
                                   OR TEXTTAB_MOD = 'X'.
        ELSE.
          CHECK <XACT> NE ORIGINAL OR TEXTTAB_MOD = 'X'.
        ENDIF.
        PERFORM PROCESS_ENTRY_RESET USING INDEX.
      ENDLOOP.
      NEWCNT = NEWCNT - ORGCNT.
      ORGCNT = ORGCNT - REFCNT.
      IF ORGCNT EQ 0 AND NEWCNT EQ 0.
        MESSAGE S016(SV) WITH REFCNT.
      ELSE.
        IF ORGCNT NE 0 AND NEWCNT NE 0.
          MESSAGE S040(SV) WITH REFCNT ORGCNT NEWCNT.
        ELSE.
          IF ORGCNT NE 0.
            MESSAGE S041(SV) WITH REFCNT ORGCNT.
          ELSE.
            MESSAGE S042(SV) WITH REFCNT NEWCNT.
          ENDIF.
        ENDIF.
      ENDIF.
      PERFORM PROCESS_AFTER_ENTRY_RESET.
    WHEN DETAIL_BILD.
      READ TABLE EXTRACT INDEX NEXTLINE. "Extract-WA i.VCL-Kontext n. ok
      PERFORM PROCESS_ENTRY_RESET USING NEXTLINE.
      MESSAGE S017(SV).
      PERFORM PROCESS_AFTER_ENTRY_RESET.
      CLEAR VIM_OLD_VIEWKEY.
      TRANSLATE VIM_NO_MAINKEY_EXISTS USING VIM_NO_MKEY_NOT_PROCSD_PATT.
  ENDCASE.
  CLEAR VIM_SPECIAL_MODE.
ENDFORM.                               "reset_entries

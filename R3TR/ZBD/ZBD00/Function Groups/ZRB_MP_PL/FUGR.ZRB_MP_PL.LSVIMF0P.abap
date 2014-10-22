*&--------------------------------------------------------------------*
*&      Form  TEMP_DELIM_UNDELETE                                     *
*&--------------------------------------------------------------------*
* process undelete of non-selected entries due to temp. delimitation  *
*&--------------------------------------------------------------------*
* TDU_ENDDA --> enddate to display during warning                     *
* TDU_ACT   --> value of action flag                                  *
* TDU_ACT_TXT --> value of action flag for text table                 *
* TDU_IX    --> index of entry to modify in TOTAL                     *
* COUNTER   <-> (global) number of undeleted entries                  *
* SY-SUBRC  <-- (global) 0 - curr. entry undeleted, others - new entry*
*&--------------------------------------------------------------------*
FORM temp_delim_undelete USING value(tdu_endda) value(tdu_begda)
                               tdu_act tdu_act_txt tdu_ix.
  LOCAL: total.
  DATA: trans_pattern(6) TYPE c, rec TYPE i, ix TYPE i.

  CLEAR tdu_ix.
  READ TABLE total WITH KEY <vim_xtotal_key> BINARY SEARCH. "#EC *
  IF sy-subrc EQ 0. "new entry already exists - must be a deleted
    "by previous temporal delimitation one
    IF <action> EQ geloescht OR <action> EQ neuer_geloescht OR
       <action> EQ update_geloescht.
      tdu_ix = sy-tabix.
      READ TABLE extract WITH KEY <vim_xtotal_key>.         "#EC *
      rec = sy-subrc. ix = sy-tabix.
      IF sy-subrc EQ 0 AND <xact> EQ markiert.
        SUBTRACT 1 FROM mark_extract.
      ELSE.
        MOVE tdu_endda TO <vim_enddate_mask>.
        IF vim_special_mode EQ vim_reset.
          MESSAGE i120(sv)."Es werden weitere Einträge zurückgeholt
        ELSE.
          MESSAGE w120(sv)."Es werden weitere Einträge zurückgeholt
        ENDIF.
      ENDIF.
      ADD 1 TO counter.
      IF rec EQ 0.                     "read table extract subrc
        sy-fdpos = vim_delim_entries-index3.
        vim_delim_entries-index3 = ix.
        APPEND vim_delim_entries.
        vim_delim_entries-index3 = sy-fdpos.
      ENDIF.
      MOVE: geloescht TO trans_pattern,
              original TO trans_pattern+1(1),
            neuer_geloescht TO trans_pattern+2(1),
              neuer_eintrag TO trans_pattern+3(1),
            update_geloescht TO trans_pattern+4(1),
              aendern TO trans_pattern+5(1).
      TRANSLATE <action> USING trans_pattern.
      MOVE <action> TO tdu_act.
      IF x_header-bastab NE space AND
         x_header-texttbexst NE space.
        TRANSLATE <action_text> USING trans_pattern.
        MOVE <action_text> TO tdu_act_txt.
      ENDIF.
      IF tdu_begda NE <vim_begdate>.   "udl entry will be modified
        MOVE: original TO trans_pattern, aendern TO trans_pattern+1.
        TRANSLATE: tdu_act USING trans_pattern,
                   tdu_act_txt USING trans_pattern.
      ENDIF.
    ENDIF.                             "current entry is a deleted one
    CLEAR sy-subrc.
  ENDIF.                               "sy-subrc eq 0
ENDFORM.                               "temp_delim_undelete

*&--------------------------------------------------------------------*
*&      Form  TIME_DEPENDENT_DISPLAY_MODIF.                           *
*&--------------------------------------------------------------------*
* process display modification (collapse/expand)                      *
*&--------------------------------------------------------------------*
FORM time_dependent_display_modif.
  DATA: ex_ix TYPE i, modif_mode(1) TYPE c, first(1) TYPE c,   "#EC NEEDED
        ex_begin TYPE i, ex_end TYPE i, key_safe TYPE vrsdat1000,
        to_ix TYPE i, rc like sy-subrc.
  READ TABLE extract INDEX nextline.
  key_safe = <vim_xextract_key>.
  CLEAR vim_mainkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  LOOP AT extract.
    ex_ix = sy-tabix.
    IF vim_no_mainkey_exists EQ vim_no_mkey_not_procsd OR
       <vim_ext_mkey_beforex> NE <vim_mkey_beforex> OR
       ( vim_mkey_after_exists NE space AND
         <vim_ext_mkey_afterx> NE <vim_mkey_afterx> ).
*       <vim_ext_mkey_before> NE <vim_mkey_before> OR
*       ( vim_mkey_after_exists NE space AND
*         <vim_ext_mkey_after> NE <vim_mkey_after> ).
      ex_end = sy-tabix - 1.
      IF modif_mode EQ 'C'.
        PERFORM collapse USING ex_begin ex_end.
        modif_mode = 'X'.
      ENDIF.                           "modif_mode eq collapse
      ex_begin = ex_ix.
      <vim_h_mkey> = <vim_xextract_key>.
*      vim_mainkey = <vim_extract_key>.
      TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_procsd_patt.
    ENDIF.                             "new mainkey in extract.
    CHECK <xmark> EQ markiert.
    READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
    <mark> = nicht_markiert. SUBTRACT 1 FROM mark_total.
    MODIFY total INDEX sy-tabix.
    SUBTRACT 1 FROM mark_extract.
    IF modif_mode CO ' X'.
      rc = 4.
      LOOP AT vim_collapsed_mainkeys.
        check <vim_collapsed_mkey_bfx> = <vim_mkey_beforex>.
*      WHERE mkey_bf EQ <vim_mkey_before>.
        IF vim_mkey_after_exists NE space.
          CHECK <vim_collapsed_key_afx> EQ <vim_mkey_afterx>.
        ENDIF.
        DELETE vim_collapsed_mainkeys.
        clear rc.
        EXIT.
      ENDLOOP.
      IF rc EQ 0.
* entry in collapsed mode -> expand
        modif_mode = 'E'.
      ELSE.
* entry in expanded mode -> collapse
        modif_mode = 'C'.
      ENDIF.
    ENDIF.
    IF modif_mode = 'E'.
      CLEAR vim_delim_entries.
      vim_delim_entries-index3 = ex_ix.
      APPEND vim_delim_entries.
      CLEAR vim_delim_entries-index3.
      vim_delim_entries-index_corr = 'X'.
      LOOP AT total.
        CHECK <vim_tot_mkey_beforex> EQ <vim_mkey_beforex> AND
              ( vim_mkey_after_exists EQ space OR
                <vim_tot_mkey_afterx> EQ <vim_mkey_afterx> ).
*        CHECK <vim_tot_mkey_before> EQ <vim_mkey_before> AND
*              ( vim_mkey_after_exists EQ space OR
*                <vim_tot_mkey_after> EQ <vim_mkey_after> ).
        to_ix = sy-tabix.
        PERFORM select USING <status>-selected.
        CHECK sy-subrc EQ 0.
        vim_delim_entries-index1 = to_ix.
        vim_delim_entries-index2 = ex_ix.
        APPEND vim_delim_entries.
      ENDLOOP.
      modif_mode = 'X'.
    ENDIF.
  ENDLOOP.
  IF modif_mode EQ 'C'.
    CLEAR vim_delim_entries.
    PERFORM collapse USING ex_begin maxlines.
  ENDIF.
  PERFORM after_temporal_delimitation.
  <vim_xextract_key> = key_safe.
  READ TABLE extract WITH KEY <vim_ext_mkey_beforex>.       "#EC *
*  READ TABLE extract WITH KEY <vim_ext_mkey_before>.
  IF sy-subrc EQ 0.
    nextline = sy-tabix.
  ELSE.
    nextline = 1.
  ENDIF.
* ENDIF.
ENDFORM.                               "time_dependent_display_modif

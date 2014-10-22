*---------------------------------------------------------------------*
*       FORM KOPIERE                                                  *
*---------------------------------------------------------------------*
* Kopieren als... und teilweise Gültigkeit abgrenzen                  *
*---------------------------------------------------------------------*
FORM kopiere.
  DATA: z LIKE sy-tabix VALUE 1,
        stat TYPE c, dum1 TYPE i.
  status-action = kopieren.
  MOVE status-data TO stat.
  status-data = auswahldaten.
  title-data = auswahldaten.
  ADD 1 TO vim_copy_call_level.
  IF vim_special_mode EQ vim_delimit.
    title-action = vim_delimit.
*  ELSEIF <STATUS>-PROF_FOUND NE VIM_PR_INTO_DET.           "UFprofile
*    TITLE-ACTION = KOPIEREN.
  ENDIF.
*  ASSIGN extract(x_header-keylen) TO <orig_key>.
  ASSIGN <vim_xextract_key> TO <orig_key>.
  IF status-mode EQ list_bild.
    LOOP AT extract.
      IF <xmark> NE markiert.
        DELETE extract.
      ELSE.
        <xmark> = nicht_markiert.
        MODIFY extract.
      ENDIF.
    ENDLOOP.
    mark_extract = <status>-mk_xt = 0.
    nextline = 1.
    DESCRIBE TABLE extract LINES maxlines.
    IF vim_copy_call_level = 1.
      VIM_NR_ENTRIES_TO_COPY = maxlines.            "SW 510129/1999
    ENDIF.
    IF status-type EQ einstufig.
      IF vim_special_mode NE vim_delimit.
        MESSAGE s024(sv).
      ELSE.
        MESSAGE s124(sv).
      ENDIF.
      CALL SCREEN liste.
      IF function NE 'ABR '.
        DESCRIBE TABLE vim_copied_indices.
        IF sy-tfill LT VIM_NR_ENTRIES_TO_COPY.     "SW 510129/1999
          "not all selected entries where proc.
          LOOP AT extract.
            READ TABLE vim_copied_indices
                 WITH KEY level = vim_copy_call_level ex_ix = z.
            IF sy-subrc EQ 0.
              DELETE extract.
            ELSE.
              <xmark> = markiert. MODIFY extract.
            ENDIF.
            ADD 1 TO z.
          ENDLOOP.
          PERFORM kopiere.
        ENDIF.
      ENDIF.
    ELSE.
      LOOP AT extract.
        IF vim_special_mode NE vim_delimit.
          neuer = 'J'.
          MESSAGE s025(sv).
        ELSE.
          MESSAGE s125(sv).
        ENDIF.
        PERFORM move_extract_to_view_wa.
        PERFORM process_detail_screen USING 'C'.
        neuer = 'N'.
        <status>-upd_flag = space.
        IF temporal_delimitation_happened NE space.
          CLEAR temporal_delimitation_happened.
        ENDIF.
        IF vim_special_mode EQ vim_delimit.
          REFRESH vim_delim_entries.
        ENDIF.
        IF function EQ 'ABR '.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF vim_copy_call_level GT 1.
      SUBTRACT 1 FROM vim_copy_call_level.
      EXIT.
    ENDIF.
    IF vim_special_mode NE vim_delimit AND counter LE 1.
      PERFORM fill_extract.
      mark_extract = mark_total.
      title-data = gesamtdaten.
      IF counter EQ 1.
        READ TABLE vim_copied_indices INDEX 1.
        READ TABLE total INDEX vim_copied_indices-ix.
        IF x_header-delmdtflag EQ space.
          READ TABLE extract WITH KEY <vim_xtotal_key>      "#EC *
                             TRANSPORTING NO FIELDS.
          nextline = sy-tabix.
        ELSE.
          nextline = 0.
          LOOP AT vim_collapsed_mainkeys.
            check <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*            WHERE mkey_bf EQ <vim_tot_mkey_before>.
            IF vim_mkey_after_exists NE space.
              CHECK <vim_collapsed_key_afx> EQ <vim_tot_mkey_afterx>.
*              CHECK <vim_collapsed_key_af> EQ <vim_tot_mkey_after>.
            ENDIF.
            READ TABLE extract WITH KEY <vim_collapsed_keyx>"#EC *
*            READ TABLE extract WITH KEY <vim_collapsed_key>
                               TRANSPORTING NO FIELDS.
            nextline = sy-tabix.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0 OR nextline EQ 0.
            READ TABLE extract WITH KEY <vim_xtotal_key>    "#EC *
                               TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              nextline = 1.
            ELSE.
              nextline = sy-tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        nextline = 1.
      ENDIF.
    ELSE.
      status-action = title-action = hinzufuegen.
      status-data = title-data = auswahldaten.
      <status>-selected = neuer_eintrag.
      REFRESH: extract, vim_delim_entries.
      CLEAR: vim_mainkey, temporal_delimitation_happened.
      TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
      mark_extract = 0.
      LOOP AT vim_copied_indices.
        READ TABLE total INDEX vim_copied_indices-ix.
        extract = total.
        APPEND extract.
        IF x_header-delmdtflag NE space.
          LOOP AT vim_collapsed_mainkeys.
            check <vim_collapsed_mkey_bfx> = <vim_ext_mkey_beforex>.
*                             WHERE mkey_bf EQ <vim_ext_mkey_before>.
            IF vim_mkey_after_exists NE space.
              CHECK <vim_collapsed_key_afx> EQ <vim_ext_mkey_afterx>.
*              CHECK <vim_collapsed_key_af> EQ <vim_ext_mkey_after>.
            ENDIF.
            READ TABLE excl_cua_funct WITH KEY function = 'EXPA'.
            IF sy-subrc NE 0.
              APPEND 'EXPA' TO excl_cua_funct.
              vim_delim_expa_excluded = 'X'.
            ENDIF.
            vim_collapsed_mainkeys-log_key =
                                        vim_collapsed_mainkeys-mkey_bf.
            CLEAR vim_collapsed_mainkeys-mkey_bf.
            MODIFY vim_collapsed_mainkeys. EXIT.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
      vim_coll_mainkeys_beg_ix = 1.
      nextline = 1.
    ENDIF.
    l = 1.
    DESCRIBE TABLE extract LINES maxlines.
  ELSE.
* Detailbild
    CLEAR <status>-mark_only.          "ufdetail
    IF vim_special_mode NE vim_delimit.
      neuer = 'J'.
      MESSAGE s025(sv).
    ELSE.
      MESSAGE s125(sv).
    ENDIF.
    PERFORM process_detail_screen USING 'C'.
    neuer = 'N'.
    <status>-upd_flag = space.
    IF function NE 'IGN ' AND function NE 'ABR '.
      IF vim_special_mode NE vim_delimit.
* copy mode
        IF status-mark EQ markiert.
          READ TABLE extract WITH KEY <orig_key> BINARY SEARCH."#EC *
          IF sy-subrc EQ 0.
            <xmark> = nicht_markiert.
            MODIFY extract INDEX sy-tabix.
            SUBTRACT 1 FROM mark_extract.
          ENDIF.
        ENDIF.
      ELSE.
* delimit mode
        IF temporal_delimitation_happened NE space.
          PERFORM after_temporal_delimitation.
        ENDIF.
      ENDIF.
      READ TABLE total WITH KEY <f1_x> BINARY SEARCH.      "#EC *
      extract = total.
*     IF <STATUS>-DISPL_MODE EQ EXPANDED OR SY-SUBRC NE 0.
      IF x_header-delmdtflag NE space.
        PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                                   'D' <vim_begdate>.
        IF sy-subrc EQ 0.
          PERFORM check_new_mainkey.
          IF sy-subrc EQ 0.
            READ TABLE vim_collapsed_mainkeys               "#EC *
             WITH KEY <vim_tot_mkey_beforex>
*            READ TABLE vim_collapsed_mainkeys WITH KEY <vim_total_key>
                                             BINARY SEARCH
                                             TRANSPORTING NO FIELDS.
            <vim_collapsed_keyx> = <vim_xtotal_key>.
*            vim_collapsed_mainkeys-mainkey = <vim_total_key>.
            <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*            vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
            INSERT vim_collapsed_mainkeys INDEX sy-tabix.
          ENDIF.
          CLEAR sy-subrc.
        ENDIF.
      ENDIF.
      IF x_header-delmdtflag EQ space OR sy-subrc LT 8.
        READ TABLE extract WITH KEY <vim_xextract_key> BINARY SEARCH"#EC *
         TRANSPORTING NO FIELDS.       "UF 333778/1999
        CASE sy-subrc.
          WHEN 0.         "UF 333778/1999, for temporal delimitation
            MODIFY extract INDEX sy-tabix.
          WHEN 4.
            INSERT extract INDEX sy-tabix.
          WHEN 8.
            APPEND extract.
        ENDCASE.
        MOVE: sy-tabix TO exind,
              sy-tabix TO nextline.
        CLEAR: old_nl.                                "GKPR - 0001009660
      ENDIF.
      IF looplines GT 0.
        IF nextline LE firstline.
          dum1 = ( firstline - nextline ) / looplines.
          ADD 1 TO dum1.
          DO dum1 TIMES.
            firstline = firstline - looplines + 1.
          ENDDO.
          IF firstline LE 0. firstline = 1. ENDIF.
        ELSE.
          dum1 = firstline + looplines - 1.
          IF nextline GT dum1.
            dum1 = ( nextline - firstline ) / looplines.
            DO dum1 TIMES.
              firstline = firstline + looplines - 1.
            ENDDO.
          ENDIF.
        ENDIF.
        l = nextline - firstline + 1.
      ELSE.
        l = nextline.
      ENDIF.
      MOVE: firstline TO <status>-firstline,
            l         TO <status>-cur_line.
      DESCRIBE TABLE extract LINES maxlines.
    ENDIF.
    MOVE: stat TO status-data,
          stat TO title-data.
  ENDIF.
  REFRESH vim_copied_indices.
  SUBTRACT 1 FROM vim_copy_call_level.
  IF vim_special_mode NE vim_delimit.
    MESSAGE s014(sv) WITH counter.
  ELSE.
    IF counter EQ 1.
      MESSAGE s122(sv).
    ELSE.
      MESSAGE s123(sv) WITH counter.
    ENDIF.
  ENDIF.
  status-action = aendern.
  IF title-action NE hinzufuegen.
    title-action = aendern.
  ENDIF.
  CLEAR vim_old_viewkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  IF function EQ 'ABR '.
    vim_next_screen = liste. vim_leave_screen = 'X'.
  ELSEIF function NE 'IGN '.
    IF vim_special_mode EQ vim_delimit AND status-mode EQ detail_bild.
      function = 'DETA'.
    ELSE.
      CLEAR function.
    ENDIF.
  ENDIF.
ENDFORM.                    "kopiere

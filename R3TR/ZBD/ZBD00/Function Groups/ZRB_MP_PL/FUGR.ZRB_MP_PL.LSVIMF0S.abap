*&--------------------------------------------------------------------*
*&      Form  AFTER_TEMPORAL_DELIMITATION                             *
*&--------------------------------------------------------------------*
* fill EXTRACT with new due to temporal delimitation entries          *
*---------------------------------------------------------------------*
*                                                                     *
*&--------------------------------------------------------------------*
FORM after_temporal_delimitation.
  LOCAL: extract, <table1>.                                 "#EC *
  DATA: index_safe TYPE i, rec TYPE i.
  DATA: extract_wa_loc(8096) TYPE c, date_loc TYPE d,
        index_start TYPE i, index_stop TYPE i,
        key_before_loc(256) TYPE c.
  FIELD-SYMBOLS: <extract_wax_loc> TYPE x, <date_loc> TYPE d,
                 <key_beforex_loc> TYPE x.
  LOOP AT vim_delim_entries WHERE index3 NE space.          "#EC *
    DELETE extract INDEX vim_delim_entries-index3.
    MOVE vim_delim_entries-index3 TO index_safe.
    IF vim_special_mode EQ vim_reset.
      SUBTRACT 1 FROM <status>-maxlines.
      IF <status>-st_mode EQ detail_bild AND
         <status>-cur_line GE vim_delim_entries-index3.
        SUBTRACT 1 FROM <status>-cur_line.
      ENDIF.
    ELSE.
      SUBTRACT 1 FROM maxlines.
    ENDIF.
    IF vim_delim_entries-index1 NE 0.
      CLEAR vim_delim_entries-index3.
      MODIFY vim_delim_entries.                             "#EC *
    ENDIF.
    LOOP AT vim_delim_entries WHERE index2 GT index_safe
                                OR  index3 GT index_safe.   "#EC *
      IF vim_delim_entries-index2 GT index_safe.
        SUBTRACT 1 FROM vim_delim_entries-index2.
      ENDIF.
      IF vim_delim_entries-index3 GT index_safe.
        SUBTRACT 1 FROM vim_delim_entries-index3.
      ENDIF.
      MODIFY vim_delim_entries.                             "#EC *
    ENDLOOP.
  ENDLOOP.
  CLEAR extract.
  LOOP AT vim_delim_entries WHERE index3 EQ space.          "#EC *
    READ TABLE total INDEX vim_delim_entries-index1.        "#EC *
    MOVE total TO extract.
    IF x_header-delmdtflag EQ 'E' AND <vim_begdate> LE sy-datum AND
       <vim_enddate> GE sy-datum OR x_header-delmdtflag EQ 'B' AND
       <vim_begdate> GE sy-datum AND <vim_enddate> LE sy-datum.
      rec = 8.
      LOOP AT vim_collapsed_mainkeys.                       "#EC *
        CHECK <vim_collapsed_mkey_bfx> EQ <vim_tot_mkey_beforex>.
*                WHERE mkey_bf EQ <vim_tot_mkey_before>.
        IF vim_mkey_after_exists NE space.
          CHECK <vim_collapsed_key_afx> EQ <vim_tot_mkey_afterx>.
*          CHECK <vim_collapsed_key_af> EQ <vim_tot_mkey_after>.
        ENDIF.
        READ TABLE extract WITH KEY <vim_collapsed_keyx>    "#EC WARNOK
*        READ TABLE extract WITH KEY <vim_collapsed_key>
                           TRANSPORTING NO FIELDS.          "#EC *
        IF sy-subrc EQ 0.
          MODIFY extract INDEX sy-tabix.                    "#EC *
          CLEAR rec.
        ENDIF.
        IF <vim_collapsed_keyx> NE <vim_xtotal_key>.
*        IF vim_collapsed_mainkeys-mainkey NE <vim_total_key>.
          <vim_collapsed_keyx> = <vim_xtotal_key>.
*          vim_collapsed_mainkeys-mainkey = <vim_total_key>.
          <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*          vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
          MODIFY vim_collapsed_mainkeys.                    "#EC *
        ENDIF.
        EXIT.
      ENDLOOP.
      CHECK rec NE 0.
    ELSE.
      PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                                 space <vim_begdate>.
      CHECK sy-subrc LT 8.
    ENDIF.
*******"HCG HW664505 new index calcualtion for insert extract BEGIN*****
    READ TABLE extract WITH KEY <vim_ext_mkey_beforex> TRANSPORTING         "#EC *
                    NO FIELDS."To check if key_before exists in extract
    IF vim_import_profile EQ space AND sy-subrc EQ 0.
      ASSIGN extract_wa_loc TO <extract_wax_loc> CASTING.
      <extract_wax_loc> = <vim_xextract>.               "save new entry
      LOOP AT x_namtab WHERE keyflag EQ 'X'
                         AND domname EQ vim_delim_date_domain
                         AND ( rollname IN vim_begda_types OR
                               rollname IN vim_endda_types ).
      ENDLOOP.                         "Only one entry should be found
      ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                      <vim_extract_struc> TO <date_loc>.
      MOVE <date_loc> TO date_loc.                   "date of new entry
      ASSIGN key_before_loc TO <key_beforex_loc> CASTING.
      <key_beforex_loc> = <vim_ext_mkey_beforex>.       "save new entry
      READ TABLE extract WITH KEY <vim_ext_mkey_beforex>.   "#EC *
      index_start = sy-tabix.
      index_stop = index_start - 1.
      LOOP AT extract FROM index_start.
        IF <key_beforex_loc> = <vim_ext_mkey_beforex>.
          index_stop = index_stop + 1.
        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
      READ TABLE extract INDEX index_start.
      IF x_namtab-rollname IN vim_endda_types.       "ENDDA is keyfield
        IF <date_loc> > date_loc.
          <vim_xextract> = <extract_wax_loc>.
          INSERT extract INDEX index_start.
        ELSE.
          LOOP AT extract FROM index_start.
            IF <date_loc> > date_loc OR sy-tabix = index_stop.
              IF <date_loc> > date_loc.
                <vim_xextract> = <extract_wax_loc>.
              ELSE.              "reached index_stop and insert behind
                <vim_xextract> = <extract_wax_loc>.
                sy-tabix = sy-tabix + 1.
              ENDIF.
              INSERT extract INDEX sy-tabix.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ELSE.                                          "BEGDA is keyfield
        IF <date_loc> < date_loc.
          <vim_xextract> = <extract_wax_loc>.
          INSERT extract INDEX index_start.
        ELSE.
          LOOP AT extract FROM index_start.
            IF <date_loc> < date_loc OR sy-tabix = index_stop.
              IF date_loc < date_loc.                                     "#EC BOOL_OK
                <vim_xextract> = <extract_wax_loc>.
              ELSE.            "reached index_stop and insert behind
                <vim_xextract> = <extract_wax_loc>.
                sy-tabix = sy-tabix + 1.
              ENDIF.
                INSERT extract INDEX sy-tabix.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ELSE.
        INSERT extract INDEX vim_delim_entries-index2.      "#EC *
      ENDIF.
*******"HCG HW664505 new index calcualtion for insert extract END*******
      ADD 1 TO maxlines.
      MOVE vim_delim_entries-index2 TO index_safe.
      LOOP AT vim_delim_entries WHERE index2 GE index_safe. "#EC *
        IF vim_delim_entries-index2 EQ index_safe.
          CHECK vim_delim_entries-index_corr NE space.
        ENDIF.
        ADD 1 TO vim_delim_entries-index2.
        MODIFY vim_delim_entries.                           "#EC *
      ENDLOOP.
    ENDLOOP.
    REFRESH vim_delim_entries.
  ENDFORM.                               "after_temporal_delimitation.

*---------------------------------------------------------------------*
*       FORM VIM_EXTERNAL_EDIT                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM vim_external_edit.
  TYPES: vee_sellist LIKE vimsellist OCCURS 10.
  DATA: ee_rc TYPE i, upd_flags(3) TYPE c, del_flags(3) TYPE c,
      h_flag(1) TYPE c, repmode_safe(1) TYPE c, specmode_safe(1) TYPE c,
        extmode_safe(1) TYPE c, vee_results LIKE vimmodres, h_ix TYPE i.
  FIELD-SYMBOLS: <h_sellist> TYPE vee_sellist, <hf> TYPE ANY.

  IF maint_mode EQ anzeigen.
    vee_results-rc_udl = vee_results-rc_ins = vee_results-rc_upd =
    vee_results-rc_del = vee_results-rc_tin = vee_results-rc_del = 8.
    vim_results_of_ext_mod = vee_results.
    EXIT.
  ENDIF.
  MOVE: aendern TO upd_flags, neuer_eintrag TO upd_flags+1,
        kopieren TO upd_flags+2,
        geloescht TO del_flags, update_geloescht TO del_flags+1,
        neuer_geloescht TO del_flags+2.
  repmode_safe = replace_mode. replace_mode = 'X'.
  specmode_safe = vim_special_mode. vim_special_mode = vim_upgrade.
  extmode_safe = vim_external_mode. vim_external_mode = 'X'.
  maxlines = 1.
  clear <status>-bcfixdelinfosent.
  LOOP AT extract.
    IF <xact> EQ zurueckholen.
      h_flag = status-delete. status-delete = geloescht.
      PERFORM vim_mark_and_process USING sy-tabix 'UNDO'
                                         vee_results-nbr_of_udl
                                         vee_results-rc_udl.
      status-delete = h_flag.
      ee_rc = vee_results-rc_udl.
    ELSEIF <xact> CO upd_flags.
      IF <xact> EQ kopieren.
        h_ix = sy-tabix + 1.
        vim_extcopy_mode = 'X'.
        <xact> = neuer_eintrag.
        ASSIGN <vim_ck_sellist> TO <h_sellist>.
        LOOP AT <h_sellist> INTO dpl_sellist
                            WHERE value EQ space AND initial EQ space.
* check if sellist is filled completely & fill it if not
          READ TABLE x_namtab INDEX dpl_sellist-tabix.
          IF sy-subrc EQ 0.
            IF x_header-bastab = space.
* view
              ASSIGN COMPONENT x_namtab-viewfield
               OF STRUCTURE <vim_total_struc> TO <hf>.
            ELSE.
              IF x_namtab-texttabfld NE space.
* Type S: text field
                ASSIGN COMPONENT x_namtab-viewfield
                 OF STRUCTURE <vim_ext_txt_struc> TO <hf>.
              ELSE.
* Type S: key field
                ASSIGN COMPONENT x_namtab-viewfield
                 OF STRUCTURE <vim_extract_struc> TO <hf>.
              ENDIF.
            ENDIF.
*            ASSIGN TOTAL+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH) TO <HF>.
            READ TABLE extract INTO total INDEX h_ix.
            dpl_sellist-value = <hf>.
            IF <hf> EQ space. dpl_sellist-initial = 'X'. ENDIF.
            CLEAR dpl_sellist-converted.
            MODIFY <h_sellist> FROM dpl_sellist.
          ENDIF.
        ENDLOOP.
      ENDIF.
      h_flag = <xact>.
      PERFORM vim_modify_view_entry USING sy-tabix ee_rc.
      CLEAR vim_extcopy_mode.
      DELETE extract.                                       "190298
      IF ee_rc EQ 0.
        IF h_flag EQ neuer_eintrag.
          ADD 1 TO vee_results-nbr_of_ins.
        ELSE.
          ADD 1 TO vee_results-nbr_of_upd.
        ENDIF.
      ELSE.
        IF h_flag EQ neuer_eintrag.
          vee_results-rc_ins = ee_rc.
        ELSE.
          vee_results-rc_upd = ee_rc.
        ENDIF.
      ENDIF.
    ELSEIF <xact> CO del_flags.
      PERFORM vim_mark_and_process USING sy-tabix 'DELE'
                                         vee_results-nbr_of_del
                                         vee_results-rc_del.
      ee_rc = vee_results-rc_del.
    ELSEIF <xact> EQ task_add.
      PERFORM vim_mark_and_process USING sy-tabix 'TRIN'
                                         vee_results-nbr_of_tin
                                         vee_results-rc_tin.
      ee_rc = vee_results-rc_tin.
    ELSEIF <xact> EQ task_del.
      PERFORM vim_mark_and_process USING sy-tabix 'TREX'
                                         vee_results-nbr_of_tex
                                         vee_results-rc_tex.
      ee_rc = vee_results-rc_tex.
    ENDIF.
    IF ee_rc EQ 8. EXIT. ENDIF.
    IF <status>-bcfixdelinfosent EQ 'X'.
      <status>-bcfixdelinfosent = 'Y'.
    ENDIF.
  ENDLOOP.
  clear <status>-bcfixdelinfosent.
  vim_results_of_ext_mod = vee_results.
* CLEAR: REPLACE_MODE, VIM_SPECIAL_MODE, VIM_EXTERNAL_MODE.
  replace_mode = repmode_safe. vim_special_mode = specmode_safe.
  vim_external_mode = extmode_safe.
ENDFORM.                               "external_edit

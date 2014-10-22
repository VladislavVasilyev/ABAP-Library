*---------------------------------------------------------------------*
*       FORM LISTE_LOESCHE                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM liste_loesche.
  DATA: rec LIKE sy-subrc,
        delete_fix_value(1) TYPE c,
        entry_contains_fix_val(1) TYPE c,
        w_field TYPE vimty_fields_type,
        bc_fix_del_info_sent(1) TYPE c VALUE ' '.

  READ TABLE extract INDEX firstline.
  IF x_header-delmdtflag <> space.
    <vim_h_old_mkey>(x_header-keylen) = <vim_xextract_key>.
  ENDIF.
*  vim_old_viewkey = <vim_extract_key>.
  counter = 0.
  LOOP AT extract.
    CHECK <xmark> EQ markiert.
*   -------Authority check before deleting fix values from BC-Sets------
    delete_fix_value = vim_bc_chng_allowed.
    IF vim_bc_chng_allowed = space.  "fix field changeability forced
      READ TABLE vim_bc_entry_list INTO vim_bc_entry_list_wa
      WITH TABLE KEY viewname = x_header-viewname
      keys = <vim_xextract_key>.
      IF sy-subrc = 0.
        CLEAR entry_contains_fix_val.
        LOOP at vim_bc_entry_list_wa-fields into w_field.
          IF w_field-flag = vim_profile_fix.
            entry_contains_fix_val = 'X'.
          ENDIF.
        ENDLOOP.
        IF entry_contains_fix_val = 'X'.
          IF bc_fix_del_info_sent EQ SPACE AND
             <status>-bcfixdelinfosent NE 'Y'."HCG: del dependent VCL
            bc_fix_del_info_sent = 'X'.
            <status>-bcfixdelinfosent = 'X'.
            MESSAGE i177(SV).
          ENDIF.
        ELSE.
          delete_fix_value = 'X'.
        ENDIF.
      ELSE.
        delete_fix_value = 'X'.
      ENDIF.
    ENDIF.
    CHECK delete_fix_value EQ 'X'.
*   -------------------------------------------------------------"HCG---
    READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH. "#EC *
    rec = sy-tabix.
    IF x_header-existency EQ 'M'.      "no mainkey delete allowed
      PERFORM check_if_entry_can_be_deleted.
      IF sy-subrc NE 0.
        <xmark> = uebergehen. ignored_entries_exist = 'X'.
        MODIFY extract.
        <mark> = uebergehen.
        MODIFY total INDEX rec.
        CONTINUE.
      ENDIF.
    ENDIF.
    PERFORM delete_check_keyrange.
    CASE sy-subrc.
      WHEN 0.
      WHEN 4. CONTINUE.
      WHEN 8. EXIT.
    ENDCASE.
    counter = counter + 1.
    PERFORM logical_delete_from_total USING rec.
    IF x_header-delmdtflag NE space.
      IF vim_special_mode NE vim_upgrade.
        PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                                   space <vim_begdate>.
      ELSE.
        CLEAR sy-subrc.
      ENDIF.
      CASE sy-subrc.
        WHEN 0. DELETE extract.
        WHEN 4.
          <f1_x> = <vim_xtotal_key>. CLEAR <vim_enddate_mask>.
          <vim_h_old_mkey>(x_header-keylen) = <f1_x>.
*          vim_old_viewkey = <f1>.
          <vim_h_mkey> = <vim_xtotal_key>.
*          vim_mainkey = <vim_total_key>.
          rec = 8.
          LOOP AT total.
            PERFORM select USING <status>-selected.
            CHECK sy-subrc EQ 0.
            CHECK <vim_tot_mkey_beforex> EQ <vim_f1_beforex> AND
               ( vim_mkey_after_exists EQ space OR
               <vim_tot_mkey_afterx> EQ <vim_f1_afterx> ). "same mainkey
*            CHECK <vim_tot_mkey_before> EQ <vim_f1_before> AND
*                  ( vim_mkey_after_exists EQ space OR
*                    <vim_tot_mkey_after> EQ <vim_f1_after> ).
            extract = total.
            PERFORM mod_extract_and_mainkey_tab USING 'M' 0.
            CLEAR rec.
            EXIT.
          ENDLOOP.
          IF rec NE 0.
            DELETE extract.
          ENDIF.
      ENDCASE.
    ELSE.
      DELETE extract.
    ENDIF.
    mark_total  = mark_total - 1.
    mark_extract = mark_extract - 1.
  ENDLOOP.
  CHECK vim_special_mode NE vim_upgrade.
  DESCRIBE TABLE extract LINES maxlines.
  IF status-action EQ hinzufuegen.
    SUBTRACT nbr_of_added_dummy_entries FROM maxlines.
  ENDIF.
  IF ignored_entries_exist EQ space AND maxlines GT 0.
    MESSAGE s011(sv) WITH counter.
  ELSE.
    MESSAGE i011(sv) WITH counter.
  ENDIF.
  IF x_header-delmdtflag <> space.
    <f1_x> = <vim_h_old_mkey>.
  ENDIF.
*  <f1> = vim_old_viewkey.
  READ TABLE extract WITH KEY <f1_x>.                        "#EC *
  IF sy-subrc EQ 0.           "HCG Otherwise sy-tabix = 0; HW681892
    rec = firstline + looplines - 1.
    IF sy-tabix GT rec OR nextline GT maxlines.
      nextline = sy-tabix.
    ENDIF.
  ELSE.
    nextline = 1.
  ENDIF.
  IF maxlines EQ 0 AND status-action EQ hinzufuegen.
    status-action = aendern.
    title-action = aendern.
    l = 1. o = 0.
  ENDIF.
  CLEAR vim_old_viewkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
ENDFORM.

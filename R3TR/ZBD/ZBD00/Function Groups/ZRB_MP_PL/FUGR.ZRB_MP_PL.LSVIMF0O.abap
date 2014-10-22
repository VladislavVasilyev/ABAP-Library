*&--------------------------------------------------------------------*
*&      Form TEMPORAL_DELIMITATION                                    *
*&--------------------------------------------------------------------*
* process temporal delimitation                                       *
*&--------------------------------------------------------------------*
FORM temporal_delimitation.
  constants: highdate TYPE d VALUE '99991231'.
  DATA: entries_exist(1) TYPE c,
        enddate_safe TYPE d, act(1) TYPE c, act_txt(1) TYPE c,   "#EC NEEDED
        hf TYPE i,                                               "#EC NEEDED
        date_safe TYPE d,                                        "#EC NEEDED
        ok_code_safe LIKE ok_code, function_safe LIKE function,
        delim_entr_safe TYPE STANDARD TABLE OF vim_delim_entr_tl
         WITH DEFAULT KEY INITIAL SIZE 10,
        collapsed_mkeys_safe TYPE STANDARD TABLE
         OF vim_collapsed_mkeys_tl WITH DEFAULT KEY INITIAL SIZE 1,
        merged_entr_safe TYPE STANDARD TABLE      "merged entries
         OF vim_merged_entr_tl WITH DEFAULT KEY INITIAL SIZE 1.

  CHECK x_header-delmdtflag NE space.
* check if dates entered properly
  IF ( <vim_new_begdate> is initial OR
     <vim_enddate_mask> EQ vim_init_date ) AND
     status-mode EQ list_bild.         "only on list screen
    MESSAGE e127(sv)."Bitte den Gültigkeitsbereich eingrenzen
  ENDIF.
* process delimitation
  IF x_header-clidep NE space.
    MOVE sy-mandt TO <client>.
  ENDIF.
  IF <xact> NE leer AND neuer NE 'J' AND status-delete NE geloescht AND
     ( status-action NE kopieren AND vim_special_mode EQ space OR
       vim_special_mode EQ vim_delimit ).
    READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
    CHECK sy-subrc EQ 0.
  ELSE. "entry is new (input, copy, undelete, reset, replace, upgrade)
    IF status-mode EQ list_bild.           "only on list screen
      IF x_header-delmdtflag EQ 'E' AND    "end date is key field
         <vim_new_begdate> GT <vim_enddate_mask>.
        MESSAGE e045(sv). "Bitte ein Beginn-Datum angeben, das vor dem
      ELSEIF x_header-delmdtflag EQ 'B' AND    "begin date is key field
             <vim_new_begdate> LT <vim_enddate_mask>.
        MESSAGE e046(sv). "Bitte ein Ende-Datum angeben, das nach dem be
      ENDIF.
    ENDIF.
    LOOP AT total.
      CHECK <vim_tot_mkey_beforex> EQ <vim_f1_beforex> AND
            ( vim_mkey_after_exists EQ space OR
              <vim_tot_mkey_afterx> EQ <vim_f1_afterx> ).
*      CHECK <vim_tot_mkey_before> EQ <vim_f1_before> AND
*            ( vim_mkey_after_exists EQ space OR
*              <vim_tot_mkey_after> EQ <vim_f1_after> ).
      MOVE 'X' TO entries_exist.
      EXIT.
    ENDLOOP.
    CHECK entries_exist NE space.
    MOVE: <table2_x> TO <vim_xtotal>,
          <vim_enddate_mask> TO <vim_enddate>.
    IF x_header-delmdtflag EQ 'E'.
      MOVE highdate TO <vim_begdate>.
    ELSE.
      CLEAR <vim_begdate>.
    ENDIF.
  ENDIF.
  CHECK <vim_new_begdate> NE <vim_begdate>.
* check allowed keyranges
  IF x_header-customauth CO sap_cust_ctrl_classes OR
     vim_ale_keyspec_check NE space OR
     vim_sync_keyspec_check NE space.
    PERFORM check_allowed_keyranges.
  ENDIF.
  IF x_header-delmdtflag EQ 'E'.       "end date is key field
    IF <vim_new_begdate> GT <vim_enddate>.
      MESSAGE e045(sv). "Bitte ein Beginn-Datum angeben, das vor dem End
    ELSEIF <vim_new_begdate> LT <vim_begdate>.
      PERFORM temp_delim_del_overld_entries USING <vim_new_begdate>
                                                  <vim_enddate>.
    ELSE.
      <vim_enddate> = <vim_new_begdate> - 1.
      IF x_header-texttbexst NE space AND
         x_header-ptfrkyexst EQ space.
        PERFORM vim_temp_delim_texttab
          USING <vim_enddate_mask> <vim_xextract_key>. "SW Texttransl
        IF x_header-bastab NE space.
          MOVE: <vim_enddate> TO <vim_text_enddate>,
                neuer_eintrag TO <action_text>.
        ENDIF.
      ENDIF.
      READ TABLE total WITH KEY <vim_xtotal_key> BINARY SEARCH  "#EC *
                                                TRANSPORTING NO FIELDS.
*      READ TABLE total WITH KEY <vim_total_key> BINARY SEARCH
*                                                TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        <action> = neuer_eintrag.
        <mark> = nicht_markiert.       "new entries are never marked
        INSERT total INDEX sy-tabix.
      ELSE.
* entry MUST be a deleted one
        MESSAGE w121(sv). "Gelöschter Eintrag wird zurückgeholt und ggf.
        PERFORM temp_delim_determine_action USING sy-tabix act act_txt.
        <action> = act.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
          <action_text> = act_txt.
        ENDIF.
        MODIFY total INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ELSE.                                "begin date is key field
    IF <vim_new_begdate> LT <vim_enddate>.
      MESSAGE e046(sv). "Bitte ein Ende-Datum angeben, das nach dem begi
    ELSEIF <vim_new_begdate> GT <vim_begdate>.
      PERFORM temp_delim_del_overld_entries USING <vim_new_begdate>
                                                  <vim_enddate>.
    ELSE.
      <vim_begdate> = <vim_new_begdate>.
      IF x_header-bastab NE space AND x_header-texttbexst NE space AND
         x_header-ptfrkyexst EQ space.
        IF <action_text> EQ original.
          MOVE aendern   TO <action_text>.
        ENDIF.
      ENDIF.
      IF <action> EQ original.
        <action> = aendern.
      ENDIF.
      MODIFY total INDEX sy-tabix.
      total = extract.
      <vim_enddate> = <vim_new_begdate> + 1.
      <action> = <xact> = neuer_eintrag.
      IF x_header-bastab NE space AND x_header-texttbexst NE space AND
         x_header-ptfrkyexst EQ space.
        MOVE: <vim_enddate> TO <vim_text_enddate>,
              neuer_eintrag TO <action_text>,
              neuer_eintrag TO <xact_text>.
      ENDIF.
      anz_pages = sy-tabix + 1.
      INSERT total INDEX anz_pages.
    ENDIF.
  ENDIF.                               "x_header-delmdtflag eq 'E'
  IF temporal_delimitation_happened EQ 'N'.
    CLEAR temporal_delimitation_happened. EXIT.
  ENDIF.
  IF temporal_delimitation_happened NE 'G'.
    MOVE sy-tabix TO anz_pages.
    LOOP AT vim_delim_entries WHERE index1 GE anz_pages.
      ADD 1 TO vim_delim_entries-index1.
      MODIFY vim_delim_entries.
    ENDLOOP.
    MOVE: anz_pages TO vim_delim_entries-index1,
          nextline  TO vim_delim_entries-index2,
          space     TO vim_delim_entries-index3.
    APPEND vim_delim_entries.
    MOVE 'X' TO temporal_delimitation_happened.
  ENDIF.
  IF <xact> NE leer AND neuer NE 'J' AND status-delete NE geloescht AND
     ( status-action NE kopieren AND vim_special_mode EQ space OR
       vim_special_mode EQ vim_delimit ).
    IF x_header-adrnbrflag NE space.
* if entry contains address number: ask if new address is wanted
      CALL FUNCTION 'POPUP_TO_DECIDE'                       "#EC *
           EXPORTING
                defaultoption = '1'
                titel         = svim_text_037
                textline1     = svim_text_038
                textline2     = svim_text_039
                textline3     = svim_text_040
                text_option1  = svim_text_041
                text_option2  = svim_text_042
           IMPORTING
                answer        = answer.
      CASE answer.
        WHEN 'A'. EXIT.
        WHEN '2'.                      "clear old address number
          CLEAR <address_number>.
        WHEN OTHERS.                   "copy old address
* not yet possible
      ENDCASE.
    ENDIF.
    IF x_header-guidflag <> space.
      PERFORM vim_make_guid USING space.
    ENDIF.
* if user exit for hidden fields exists: perform exit routine
    IF x_header-frm_h_flds NE space.
      PERFORM (x_header-frm_h_flds) IN PROGRAM.
    ENDIF.
* if user exit for new entries exists: perform exit routine
    IF x_header-frm_on_new NE space.
      PERFORM (x_header-frm_on_new) IN PROGRAM.
    ENDIF.
* if entry contains address number: call address maintain
    IF x_header-adrnbrflag NE space AND answer EQ '2'.
      PERFORM address_maintain.
    ENDIF.
* if user exit after delimitation exists: perform exit routine
    IF x_header-frm_af_dlm NE space.
      delim_entr_safe = vim_delim_entries[].
      collapsed_mkeys_safe = vim_collapsed_mainkeys[].
      merged_entr_safe = vim_merged_entries[].
      IF status-mode EQ detail_bild.
        ok_code_safe = ok_code. function_safe = function.
      ENDIF.
      PERFORM (x_header-frm_af_dlm) IN PROGRAM.
      MOVE delim_entr_safe TO vim_delim_entries[].
      MOVE collapsed_mkeys_safe TO vim_collapsed_mainkeys[].
      MOVE merged_entr_safe TO vim_merged_entries[].
      IF status-mode EQ detail_bild.
        MOVE: ok_code_safe TO ok_code, function_safe TO function.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               "temp_delimitation

*----------------------------------------------------------------------*
*   INCLUDE LSVIMFX2                                                   *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM DETAILBILD                                               *
*---------------------------------------------------------------------*
*       .........                                                     *
*---------------------------------------------------------------------*
FORM detailbild.
  IF status-mode NE list_bild OR status-type NE zweistufig.
    MESSAGE i001(sv).
    EXIT.
  ENDIF.
  nextline = firstline + l - 1.
  IF l EQ 0 OR nextline GT maxlines.
    MESSAGE s032(sv).
    MOVE firstline TO nextline.
    EXIT.
  ENDIF.
  IF mark_extract > 0.                 "ufdetailb
    PERFORM set_mark_only USING nextline.
  ENDIF.                               "ufdetaile
  IF x_header-delmdtflag NE space.
    TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  ENDIF.
  PERFORM process_detail_screen USING 'S'.
ENDFORM.                    "detailbild
*---------------------------------------------------------------------*
*       FORM DETAIL_ABBRECHEN
**---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail_abbrechen.
  IF replace_mode EQ space AND
     ( sy-datar NE space OR
       ( x_header-bastab EQ space OR x_header-texttbexst EQ space )
       AND <table1_x> NE <table2_x>
       OR  x_header-bastab NE space AND x_header-texttbexst NE space
       AND ( <table1_x> NE <vim_xextract_enti>
             OR <table1_xtext> NE <vim_xextract_text> ) ).
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        titel          = svim_text_007
        textline1      = svim_text_009
        textline2      = svim_text_006
        defaultoption  = 'N'
        cancel_display = ' '
      IMPORTING
        answer         = answer.                            "#EC *
    IF answer NE 'J'.
      EXIT.
    ENDIF.
  ENDIF.
  IF status-action EQ kopieren.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
  IF maxlines LE 1.
*   IF STATUS-ACTION EQ HINZUFUEGEN OR STATUS-ACTION EQ KOPIEREN.
    IF status-action EQ hinzufuegen.
      status-action = aendern.
      title-action  = aendern.
      CLEAR <status>-selected.
    ENDIF.
    PERFORM fill_extract.
    nextline = 1.
  ENDIF.
  neuer = 'N'.
  IF vim_single_entry_function EQ space.
    <status>-upd_flag = space.
    IF replace_mode EQ space AND vim_special_mode NE vim_delete.
      l = nextline - <status>-firstline + 1.
      IF l LE 0 OR l GT looplines.
        l = 1.
      ENDIF.
      nextline = <status>-firstline.
      SET SCREEN liste.
    ELSE.
      SET SCREEN 0. CLEAR vim_act_dynp_view.
    ENDIF.
  ELSE.                                "single_entry_function
    function = end. SET SCREEN 0. CLEAR vim_act_dynp_view.
    PERFORM update_status.
  ENDIF.
  LEAVE SCREEN.
ENDFORM.                    "detail_abbrechen
*---------------------------------------------------------------------*
*       FORM DETAIL_BACK                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail_back.

  DATA:count TYPE i.

  CASE status-action.
    WHEN aendern.
      PERFORM update_tab.
    WHEN hinzufuegen.
*      WRITE <f1> TO entry(x_header-keylen).
      MOVE <f1_x> TO <f1_wax>.
      PERFORM update_tab.
      neuer = 'N'.
*      SORT extract BY <vim_extract_key>.
      SORT extract BY <vim_xextract_key>.                   "#EC *
*      MOVE entry TO <table1>.
*      READ TABLE extract WITH KEY <f1> BINARY SEARCH.
      READ TABLE extract WITH KEY <f1_x>.                   "#EC *
      firstline = 1.
      IF sy-tabix GT looplines AND looplines GT 0.
        count = ( sy-tabix - firstline ) DIV looplines + 1.
        DO count TIMES.
          firstline = firstline + looplines - 1.
        ENDDO.
        MOVE firstline TO <status>-firstline.
      ENDIF.
      l = sy-tabix - firstline + 1.
      MOVE l TO <status>-cur_line.
      MOVE <initial> TO <table1>.
      IF x_header-bastab NE space AND x_header-texttbexst NE space.
        MOVE <text_initial_x> TO <table1_xtext>.
*        MOVE <text_initial> TO <table1_text>.
      ENDIF.
  ENDCASE.
  IF status-data EQ auswahldaten AND maxlines LE 1.
    <table1_wax> = <vim_xextract>.
    IF status-delete = geloescht.
      status-delete = nicht_geloescht.
      title-action  = aendern.
      PERFORM markiere_alle USING nicht_markiert.
    ENDIF.
    IF status-action EQ hinzufuegen.
      status-action = aendern.
      title-action  = aendern.
      CLEAR <status>-selected.
    ENDIF.
    IF x_header-delmdtflag NE space.
      <vim_h_mkey>(x_header-keylen) = <f1_x>.
      LOOP AT vim_collapsed_mainkeys."#EC * "WHERE mkey_bf EQ <vim_f1_before>.
        IF vim_collapsed_mainkeys-mkey_bf EQ space. "SW: wie liste_back
* change XB 11.06.02 BCEK060520/BCEK060521 ----------begin--------------
* if <vim_collapsed_mkey_bfx> should be changed, only when it isn't
* constant 4B00, that means data isn't at position 0.
          IF <vim_collapsed_mkey_bfx> NE <vim_mkey_beforex>.
            <vim_collapsed_mkey_bfx> = <vim_collapsed_logkeyx>.
*          vim_collapsed_mainkeys-mkey_bf =
*                                       vim_collapsed_mainkeys-log_key.
          ENDIF.
* change XB 11.06.02 BCEK060520/BCEK060521 ------------end--------------
          CLEAR vim_collapsed_mainkeys-log_key.
        ENDIF.                                              "SW
        <f1_x> = <vim_h_coll_mkey>.
*        <f1> = vim_collapsed_mainkeys-mainkey.
        <vim_enddate_mask> = space.
        <vim_h_coll_mkey> = <f1_x>.
*        vim_collapsed_mainkeys-mainkey = <f1>.
        MODIFY vim_collapsed_mainkeys.                      "#EC *
      ENDLOOP.
      IF vim_delim_expa_excluded NE space.
        DELETE excl_cua_funct WHERE function EQ 'EXPA'.
        CLEAR vim_delim_expa_excluded.
      ENDIF.
      IF status-action = aendern AND title-action = hinzufuegen.
        title-action  = aendern.
      ENDIF.
    ENDIF.
    PERFORM fill_extract.
*    <table1> = entry(x_header-keylen).
*    READ TABLE extract WITH KEY <f1>.
    READ TABLE extract WITH KEY <f1_wax>."#EC *
    IF sy-subrc EQ 0.
      nextline = sy-tabix.
    ELSE.
      nextline = 1.
    ENDIF.
  ELSE.
    MOVE firstline TO nextline.
  ENDIF.
  vim_next_screen = liste. vim_leave_screen = 'X'.
ENDFORM.                    "detail_back
*&--------------------------------------------------------------------*
*&      Form  DETAIL_EXIT_COMMAND                                     *
*&--------------------------------------------------------------------*
* handle exit commands on detail screen                               *
*&--------------------------------------------------------------------*
FORM detail_exit_command.
  DATA: answer.                                            "#EC NEEDED
  function = ok_code.
  CLEAR vim_old_viewkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  CASE ok_code.
    WHEN 'ABR '.
      CLEAR ok_code.
      PERFORM detail_abbrechen.
    WHEN 'IGN '.
      PERFORM ignorieren.
    WHEN 'UPRF'.                       "UFprofileB
      CHECK vim_pr_activating = space.
*      IF SY-DATAR <> SPACE.
*        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
*             EXPORTING
*                  TEXTLINE1      = SVIM_TEXT_PRF
*                  TEXTLINE2      = SVIM_TEXT_PRG
*                  TITEL          = SVIM_TEXT_PRE
*                  CANCEL_DISPLAY = ' '
*             IMPORTING
*                  ANSWER         = ANSWER.
*        IF ANSWER <> 'J'.
*          CLEAR: FUNCTION, OK_CODE.
*        ENDIF.
*      ENDIF.
      IF NOT function IS INITIAL.
        PERFORM vim_pr_mand_fields.
      ENDIF.
    WHEN 'GPRF'.
      CHECK vim_pr_activating = space.
      PERFORM vim_pr_mand_fields         .         "UFprofileE
  ENDCASE.
ENDFORM.                               "detail_exit_command
*---------------------------------------------------------------------*
*       FORM DETAIL_INIT                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail_init.
  CONSTANTS: forward VALUE 'X'.                                "#EC NEEDED
  IF function NE space.
    status-mode = detail_bild.
    title-mode  = detail_bild.
    IF <xmark> EQ markiert.
      status-mark = markiert.
    ELSE.
      status-mark = nicht_markiert.
    ENDIF.
    IF status-action NE kopieren AND neuer NE 'J'.
      IF <status>-selected = by_field_contents AND nextline > maxlines.
        nextline = 1.                  "377434/1999 UF011299
      ENDIF.
      IF x_header-subsetflag NE space AND replace_mode EQ space.
        PERFORM fill_subsetfields.
      ENDIF.
* ========== XB int225314/03 H601454 begin ==========
* maxlines must GT nextline in EXTRACT, otherweise the
* empty entry in EXTRACT will be readed.
      IF nextline > maxlines.
        PERFORM read_table USING maxlines.
      ELSE.
        PERFORM read_table USING nextline.
      ENDIF.
* ========== XB int225314/03 H601454 end   ==========
      IF x_header-subsetflag NE space.
        PERFORM complete_subsetfields.
      ENDIF.
    ENDIF.
    IF vim_special_mode EQ vim_delimit.
      MOVE vim_sval_tab-value TO <vim_new_begdate>.
    ENDIF.
  ENDIF.
  CLEAR: vim_key_alr_checked, vim_keyrange_alr_checked.
  vim_act_dynp_view = x_header-viewname.
  PERFORM set_title USING title <name>.
  CASE replace_mode.
    WHEN space.
*     SET PF-STATUS STATUS EXCLUDING EXCL_CUA_FUNCT.
      IF neuer NE 'X'. "error in CHECK_KEY for timedep. objects
        IF vim_special_mode NE vim_delete.
          PERFORM set_pf_status USING status.
        ELSE.
          PERFORM set_pf_status USING 'REPLACE'.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
*     SUPPRESS DIALOG.
*     SET PF-STATUS 'REPLACE'.
      PERFORM set_pf_status USING 'REPLACE'.
*     IF X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE.
*     IF VIM_SPECIAL_MODE NE VIM_UPGRADE AND
*        X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE.
*       IF REPLACE_TEXTTABLE_FIELD NE SPACE.
*         MOVE 'T' TO <STATUS>-UPD_FLAG.
*       ELSE.
*         MOVE 'E' TO <STATUS>-UPD_FLAG.
*       ENDIF.
*     ELSE.
*       MOVE 'X' TO <STATUS>-UPD_FLAG.
*     ENDIF.
*     EXIT.
  ENDCASE.
ENDFORM.                    "detail_init
*---------------------------------------------------------------------*
*       FORM DETAIL_LOESCHE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail_loesche.
  DATA: tot_ix LIKE sy-tabix, rec LIKE sy-subrc,
        delete_fix_value(1) TYPE c,
        entry_contains_fix_val(1) TYPE c,
        w_field TYPE vimty_fields_type,
        bc_fix_del_info_sent(1) TYPE c VALUE ' '.

*   -------Authority check before deleting fix values from BC-Sets------
  delete_fix_value = vim_bc_chng_allowed.
  IF vim_bc_chng_allowed = space.  "fix field changeability forced
    READ TABLE vim_bc_entry_list INTO vim_bc_entry_list_wa
    WITH TABLE KEY viewname = x_header-viewname
    keys = <vim_xextract_key>.
    IF sy-subrc = 0.
      CLEAR entry_contains_fix_val.
      LOOP AT vim_bc_entry_list_wa-fields INTO w_field.
        IF w_field-flag = vim_profile_fix.
          entry_contains_fix_val = 'X'.
        ENDIF.
      ENDLOOP.
      IF entry_contains_fix_val = 'X'.
        IF bc_fix_del_info_sent EQ space AND
           <status>-bcfixdelinfosent NE 'Y'."HCG: del dependent VCL
          bc_fix_del_info_sent = 'X'.
          <status>-bcfixdelinfosent = 'X'.
          MESSAGE i177(sv).
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
  IF <xmark> NE uebergehen.
    READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
    MOVE sy-tabix TO tot_ix.
    IF x_header-existency EQ 'M'.      "no mainkey delete allowed
      PERFORM check_if_entry_can_be_deleted.
      IF sy-subrc NE 0.
        <xmark> = uebergehen. ignored_entries_exist = 'X'.
        MODIFY extract INDEX nextline.                      "#EC *
        <mark> = uebergehen.
        MODIFY total INDEX tot_ix.                          "#EC *
        EXIT.
      ENDIF.
    ENDIF.
    PERFORM logical_delete_from_total USING tot_ix.
    IF <xmark> EQ markiert.
      mark_total  = mark_total - 1.
      mark_extract = mark_extract - 1.
    ENDIF.
    IF x_header-delmdtflag NE space.
      IF vim_special_mode NE vim_upgrade.
        PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                                   space <vim_begdate>.
      ELSE.
        CLEAR sy-subrc.
      ENDIF.
    ENDIF.
    IF x_header-delmdtflag EQ space OR sy-subrc LT 8.
      rec = sy-subrc.
      DELETE extract INDEX nextline.
*MN 421570 2005
      DESCRIBE TABLE extract LINES maxlines.
      IF rec EQ 4.
        LOOP AT total.                                      "#EC *
          PERFORM select USING <status>-selected.
          CHECK sy-subrc EQ 0.
          CHECK <vim_tot_mkey_beforex> EQ <vim_old_mkey_beforex> AND
                ( vim_mkey_after_exists EQ space OR
                  <vim_tot_mkey_afterx> EQ <vim_old_mkey_afterx> ).
*          CHECK <vim_tot_mkey_before> EQ <vim_old_mkey_before> AND
*                ( vim_mkey_after_exists EQ space OR
*                  <vim_tot_mkey_after> EQ <vim_old_mkey_after> ).
          vim_mainkey = vim_old_viewkey.
          extract = total.
          PERFORM mod_extract_and_mainkey_tab USING 'I' nextline.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDIF.
    IF vim_special_mode EQ vim_upgrade.
      counter = 1.
      EXIT.
    ENDIF.
    IF ignored_entries_exist EQ space AND maxlines GT 1.
      MESSAGE s013(sv).
    ELSE.
      MESSAGE i013(sv).
    ENDIF.
  ENDIF.
  IF <status>-mark_only <> space.      "ufdetailb
    DESCRIBE TABLE extract LINES maxlines.
    IF mark_extract = 0.
* last marked entry deleted
      nextline = 1.
      vim_next_screen = liste. vim_leave_screen = 'X'.
    ELSE.
* search next marked entry
      nextline = nextline - 1.
      PERFORM get_marked_entry USING 'X'
                  CHANGING nextline
                           rec.
      IF rec <> 0.
* search previous marked entry
        nextline = nextline + 1.
        PERFORM get_marked_entry USING space
                    CHANGING nextline
                             rec.
      ENDIF.
      IF rec <> 0.
        nextline = 1. vim_next_screen = liste. vim_leave_screen = 'X'.
      ELSE.
        PERFORM get_page_and_position USING nextline
                                            looplines
                                      CHANGING firstline
                                               l.
      ENDIF.
    ENDIF.

  ELSE.                                "ufdetaile
    DESCRIBE TABLE extract LINES maxlines.
    IF maxlines EQ 0.
      nextline = 1.
      IF status-action EQ hinzufuegen.
        status-action = aendern.
        title-action = aendern.
      ENDIF.
      PERFORM fill_extract.
      vim_next_screen = liste. vim_leave_screen = 'X'.
    ENDIF.
    IF nextline GT maxlines.
      nextline = maxlines.
    ENDIF.
  ENDIF.                               "ufdetail
  READ TABLE total INDEX tot_ix.                            "#EC *
  CLEAR vim_old_viewkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
ENDFORM.                    "detail_loesche
*---------------------------------------------------------------------*
*       FORM DETAIL_MARKIERE                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail_markiere.
  IF neuer EQ 'J'.
    EXIT.
  ENDIF.
  PERFORM update_tab.
* PERFORM MARKIERE USING FIRSTLINE.
  PERFORM markiere USING nextline.
  CLEAR function.
ENDFORM.                    "detail_markiere


*---------------------------------------------------------------------*
*       FORM DETAIL_MARKIERTE                                         *
*---------------------------------------------------------------------*
*       UF300798 Detail-screen only with marked entries except line-
*                selection on list-screen
*---------------------------------------------------------------------*
FORM detail_markierte.

  DATA: rc LIKE sy-subrc.

  IF status-mode NE list_bild OR status-type NE zweistufig.
    MESSAGE i001(sv).
    EXIT.
  ENDIF.
  IF mark_extract = 0.
* no entries marked
    PERFORM detailbild.
    EXIT.
  ENDIF.
  <status>-mark_only = 'X'.
** current entry marked?
*  nextline = firstline + l - 1.
*  PERFORM check_marked USING nextline
*                       CHANGING rc.
*  IF rc <> 0.
* search first marked entry
  nextline = 0.
  PERFORM get_marked_entry USING 'X'
                           CHANGING nextline
                                    rc.
  IF rc <> 0. PERFORM detailbild. EXIT. ENDIF.
*  ENDIF.
  IF x_header-delmdtflag NE space.
    TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  ENDIF.
  PERFORM process_detail_screen USING 'S'.
ENDFORM.                    "detail_markierte

*---------------------------------------------------------------------*
*       FORM DETAIL_PAI                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* <--- NEXT_SCREEN - next screen to process                           *
* <--- LEAVE_SCREEN - flag: X - leave screen necessary                *
*---------------------------------------------------------------------*
FORM detail_pai.
  CLEAR: vim_next_screen, vim_leave_screen.
  MOVE: status-data TO <status>-st_data,
        status-mode TO <status>-st_mode,
        status-delete TO <status>-st_delete,
        status-action TO <status>-st_action,
        title         TO <status>-title,
        maxlines      TO <status>-maxlines,
        mark_extract  TO <status>-mk_xt,
        mark_total    TO <status>-mk_to,
        function      TO <status>-fcode.
  IF x_header-ptfrkyexst NE space.
    PERFORM consistency_prt_frky_fields USING 'X'.
  ENDIF.
* IF TEMPORAL_DELIMITATION_HAPPENED NE SPACE AND
*    STATUS-ACTION NE KOPIEREN.
  IF <status>-prof_found <> space.
    CLEAR vim_pr_fields_wa.            "UFprofiles
  ENDIF.
  IF vim_special_mode NE vim_upgrade AND
     temporal_delimitation_happened NE space AND
     status-action NE kopieren.
    PERFORM update_tab.
    PERFORM after_temporal_delimitation.
    CLEAR temporal_delimitation_happened.
    PERFORM check_if_entry_is_to_display USING 'L' <f1_x> space
                                               <vim_begdate>.
    IF status-action EQ hinzufuegen.
      IF function NE 'NEXT'.
        CASE sy-subrc.
          WHEN 0.                      "expanded mode or new entry
            PERFORM read_table USING nextline.
          WHEN 4.                      "collapsed mode and actual entry
            READ TABLE extract WITH KEY <f1_x>.            "#EC *
            nextline = sy-tabix.
            extract = total.
            CLEAR function.
          WHEN OTHERS.                 "collapsed mode and other entry
            LOOP AT extract.                                "#EC *
              CHECK <vim_ext_mkey_beforex> EQ <vim_f1_beforex> AND
                    ( vim_mkey_after_exists EQ space OR
                    <vim_ext_mkey_afterx> EQ <vim_f1_afterx> ).
              nextline = sy-tabix.
              EXIT.
            ENDLOOP.
            extract = total.
            CLEAR function.
        ENDCASE.
      ENDIF.
    ELSE.
      IF sy-subrc EQ 0.
        ADD 1 TO exind.
        nextline = exind.
      ENDIF.
    ENDIF.
  ENDIF.
* FUNCTION = OK_CODE.
  CLEAR ok_code.
  IF replace_mode NE space AND
     ( vim_special_mode NE vim_upgrade OR
       NOT function IN exted_functions ).
    PERFORM update_tab.
*   SET SCREEN 0.
    vim_next_screen = 0. vim_leave_screen = 'X'.
    EXIT.
  ELSEIF vim_special_mode EQ vim_delete.
    vim_next_screen = 0. vim_leave_screen = 'X'. EXIT.
  ENDIF.
  IF vim_single_entry_function NE space AND function NE space.
    IF vim_single_entry_ins_key_input EQ space.
      TRANSLATE status-action USING 'AU'. status-data = gesamtdaten.
    ENDIF.
    IF function EQ 'UEBE'.
      function = 'ENDE'.
    ENDIF.
  ENDIF.
  CASE function.
    WHEN 'ADDR'.
      PERFORM address_maintain.
    WHEN 'AEND'.
      PERFORM anzg_to_aend.
    WHEN 'ALCO'.
      PERFORM selektiere USING transportieren.
    WHEN 'ALMK'.
      PERFORM selektiere USING markiert.
    WHEN 'ALNC'.
      PERFORM selektiere USING space.
    WHEN 'ALOE'.
      PERFORM selektiere USING geloescht.
    WHEN 'ALNW'.
      PERFORM selektiere USING neuer_eintrag.
    WHEN 'ANZG'.
      PERFORM update_tab.
      IF l EQ 0. MOVE: 1 TO l, 1 TO <status>-cur_line. ENDIF.
*        SET SCREEN 0. LEAVE SCREEN.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'ATAB'.
      PERFORM update_tab.
      IF l EQ 0. MOVE: 1 TO l, 1 TO <status>-cur_line. ENDIF.
*     SET SCREEN 0. LEAVE SCREEN.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'BCCH'.                       "change fix bc-set fields
      PERFORM vim_chng_fix_flds.
    WHEN 'BCSH'.                        " show fix bc-set fields
      PERFORM vim_bc_show_fix_flds.
    WHEN 'DELE'.
*     PERFORM DETAIL_LOESCHE.
      PERFORM loeschen.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        EXIT.
      ENDIF.
    WHEN 'DELM'.
      PERFORM delimitation.
    WHEN 'ENDE'.
      PERFORM update_tab.
      IF l EQ 0. MOVE: 1 TO l, 1 TO <status>-cur_line. ENDIF.
*     SET SCREEN 0. LEAVE SCREEN.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'EXPA'.
*     perform ........
    WHEN 'FDOC'.                       "HW Functiondocu
      PERFORM show_function_docu.
      CLEAR function.
*    WHEN 'GPRF'.                       "UF Profile
* choose profile
*      CLEAR: <status>-prof_found, vim_pr_records.
*      PERFORM get_profiles USING <status>-prof_found.
    WHEN 'KOPE'.
      counter = 0.
      PERFORM kopiere.
    WHEN 'KOPF'.
*       IF X_HEADER-ADRNBRFLAG NE SPACE.
*         PERFORM ADDRESS_MAINTAIN.
*       ENDIF.
      PERFORM kopiere_eintrag USING <orig_key>.
    WHEN 'LANG'.                       "SW Texttransl
      PERFORM vim_set_languages.
      CLEAR function.
    WHEN 'MKEZ'.
      PERFORM detail_markiere.
    WHEN 'NEWL'.
      PERFORM update_tab.
      CLEAR <status>-mark_only.        "UFdetail
      PERFORM hinzufuegen.
    WHEN 'NEXT'.
      PERFORM naechster.
    WHEN 'ORDR'.
      PERFORM order_administration.
    WHEN 'ORGI'.
      PERFORM original_holen.
    WHEN 'POSI'.
      PERFORM popup_positionieren.
    WHEN 'PREV'.
      PERFORM voriger.
    WHEN 'PRMO'.
* 4.6A: obsolete, left only for individual status
      PERFORM update_tab.
      PERFORM list_alv.
    WHEN 'PROT'.
      PERFORM logs_analyse.
    WHEN 'PRST'.
      PERFORM update_tab.
      PERFORM list_alv.
    WHEN 'SAVE'.
      PERFORM update_tab.
      IF status-action EQ hinzufuegen.
        SORT extract BY <vim_xextract_key>.                "#EC WARNOK
*        READ TABLE extract WITH KEY extract BINARY SEARCH.
        READ TABLE extract WITH KEY <vim_xextract_key>.     "#EC *
        <status>-cur_line = l = sy-tabix - firstline + 1.
      ENDIF.
*     SET SCREEN 0. LEAVE SCREEN.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'SCRF'.
      PERFORM update_tab.
      PERFORM vim_sapscript_form_maint.
    WHEN 'SEAR'.
      PERFORM update_tab.
      PERFORM suchen.
    WHEN 'SELU'.
      PERFORM selektiere USING aendern.
    WHEN 'TEXT'.
      PERFORM update_tab.
      PERFORM vim_multi_langu_text_maint.
    WHEN 'TREX'.
      MOVE geloescht TO corr_action.
      PERFORM update_corr.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        EXIT.
      ENDIF.
    WHEN 'TRIN'.
      MOVE hinzufuegen TO corr_action.
      PERFORM update_corr.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        EXIT.
      ENDIF.
    WHEN 'TRSP'.
*     SET SCREEN 0. LEAVE SCREEN.
      IF x_header-cursetting NE space AND
         x_header-flag EQ vim_transport_denied.
        x_header-flag = x_header-cursetting.
        TRANSLATE x_header-flag USING 'X YX'.
        MODIFY x_header INDEX 1.                            "#EC *
      ENDIF.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'UEBE'.
      PERFORM detail_back.
    WHEN 'UPRF'.
* activate chosen profile
*      PERFORM activate_profile CHANGING <status>-prof_found.
      MESSAGE s175(sv).
    WHEN 'UNDO'.
*     PERFORM DETAIL_ZURUECKHOLEN.
      PERFORM zurueckholen.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        EXIT.
      ENDIF.
    WHEN '    '.
      IF vim_prt_fky_flds_updated NE space.
        CLEAR vim_prt_fky_flds_updated.
        PERFORM update_tab.
      ELSE.
        IF x_header-frm_h_flds NE space.
          PERFORM (x_header-frm_h_flds) IN PROGRAM.         "#EC *
        ENDIF.
        IF neuer EQ 'J' AND vim_key_alr_checked EQ space.
*          IF x_header-guidflag <> space.
*            PERFORM vim_make_guid.
*          ENDIF.
          IF x_header-frm_on_new NE space.
            PERFORM (x_header-frm_on_new) IN PROGRAM.       "#EC *
          ENDIF.
        ENDIF.
        PERFORM check_key.
      ENDIF.
    WHEN OTHERS.
      IF vim_called_by_cluster NE space.                    "SW Crtl ..
        CALL FUNCTION 'VIEWCLUSTER_NEXT_ACTION'
          EXPORTING
            detail       = 'X'
          IMPORTING
            leave_screen = vim_leave_screen
          CHANGING
            fcode        = function.
        IF vim_leave_screen NE space.
          PERFORM update_tab.
          vim_next_screen = 0.
        ENDIF.
      ENDIF.                           ".. SW Ctrl
  ENDCASE.
ENDFORM.                    "detail_pai

*---------------------------------------------------------------------*
*       FORM DETAIL_ZURUECKHOLEN                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM detail_zurueckholen.
  DATA: tot_ix LIKE sy-tabix, msg_type(1) TYPE c, msg_no LIKE sy-msgno,
        rc LIKE sy-subrc.
  IF x_header-delmdtflag NE space.
    counter = 1.
    PERFORM temporal_delimitation.
  ENDIF.
  IF <xmark> EQ markiert.
    mark_total  = mark_total - 1.
    mark_extract = mark_extract - 1.
  ENDIF.
  READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
  MOVE sy-tabix TO tot_ix.
  PERFORM logical_undelete_total USING sy-tabix.
  IF temporal_delimitation_happened NE space.
    CLEAR vim_delim_entries.
    PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                               space <vim_begdate>.
    IF sy-subrc LT 8.
      vim_delim_entries-index3 = nextline.
      IF sy-subrc EQ 4.
        LOOP AT total.                                      "#EC *
          CHECK <action> EQ geloescht OR <action> EQ neuer_geloescht OR
                <action> EQ update_geloescht.
          CHECK <vim_tot_mkey_beforex> EQ <vim_old_mkey_beforex> AND
                ( vim_mkey_after_exists EQ space OR
                  <vim_tot_mkey_afterx> EQ <vim_old_mkey_afterx> ).
*          CHECK <vim_tot_mkey_before> EQ <vim_old_mkey_before> AND
*                ( vim_mkey_after_exists EQ space OR
*                  <vim_tot_mkey_after> EQ <vim_old_mkey_after> ).
          vim_delim_entries-index1 = sy-tabix.
          vim_delim_entries-index2 = vim_delim_entries-index3.
          EXIT.
        ENDLOOP.
      ENDIF.
      APPEND vim_delim_entries.                             "#EC *
    ENDIF.
    PERFORM after_temporal_delimitation.
    CLEAR temporal_delimitation_happened.
  ELSE.
    IF replace_mode NE space AND vim_external_mode EQ space.
      extract = total.
      MODIFY extract INDEX nextline."#EC * "no deletion in upgrade mode
    ELSE.
      DELETE extract INDEX nextline.                        "#EC *
      SUBTRACT 1 FROM maxlines.
    ENDIF.
  ENDIF.
  IF replace_mode EQ space.
    IF counter GT 1. msg_no = '002'. ELSE. msg_no = '003'. ENDIF.
    IF ignored_entries_exist EQ space.
      msg_type = 'S'.
    ELSE.
      msg_type = 'W'.
    ENDIF.
    MESSAGE ID 'SV' TYPE msg_type NUMBER msg_no WITH counter.
    IF nextline NE 1 AND nextline GT maxlines.
      nextline = maxlines.
    ENDIF.
    IF maxlines EQ 0.
      title-action = aendern.
      status-delete = nicht_geloescht.
      vim_next_screen = liste. vim_leave_screen = 'X'.
    ELSEIF <status>-mark_only <> space.
      IF mark_extract = 0.
* last marked entry deleted
        nextline = 1.
        vim_next_screen = liste. vim_leave_screen = 'X'.
      ELSE.
* search next marked entry
        nextline = nextline - 1.
        PERFORM get_marked_entry USING 'X'
                    CHANGING nextline
                             rc.
        IF rc <> 0.
* search previous marked entry
          nextline = nextline + 1.
          PERFORM get_marked_entry USING space
                      CHANGING nextline
                               rc.
        ENDIF.
        IF rc <> 0.
          nextline = 1. vim_next_screen = liste. vim_leave_screen = 'X'.
        ELSE.
          PERFORM get_page_and_position USING nextline
                                              looplines
                                        CHANGING firstline
                                                 l.
        ENDIF.
      ENDIF.
    ENDIF.
    READ TABLE total INDEX tot_ix.                          "#EC *
  ELSE.
    counter = 1.
  ENDIF.
  CLEAR vim_old_viewkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
ENDFORM.                    "detail_zurueckholen

*&---------------------------------------------------------------------*
*&      Form  GET_MARKED_ENTRY
*&---------------------------------------------------------------------*
*       Search marked entries in EXTRACT beginning at index p_index
*----------------------------------------------------------------------*
*      -->P_FORWARD  'X': search forward
*                    ' ': search backward
*      <--P_index    in: start from here (including)
*                    out: index of first marked entry found
*      <--P_RC       0: further marked entry found
*                    4: no further marked entry found
*----------------------------------------------------------------------*
FORM get_marked_entry USING    p_forward TYPE sychar01
                      CHANGING p_index LIKE sy-tabix
                               p_rc LIKE sy-subrc.
  DATA: bw_index LIKE sy-tabix.

  p_rc = 4.
  IF p_forward IS INITIAL.
* search backward
    bw_index = p_index - 1.
    WHILE bw_index > 0.
      READ TABLE extract INDEX bw_index.                    "#EC *
      IF <xmark> = markiert.
        p_index = bw_index.
        old_nl = p_index.                                   "GKPR - 0001009660
        CLEAR p_rc.
        EXIT.
      ENDIF.
      bw_index = bw_index - 1.
    ENDWHILE.
  ELSE.
* search forward.
    p_index = p_index + 1.
    LOOP AT extract FROM p_index.                           "#EC *
      CHECK <xmark> = markiert.
      p_index = sy-tabix.
      old_nl = p_index.                                     "GKPR - 0001009660
      CLEAR p_rc.
      EXIT.
    ENDLOOP.
    IF p_rc > 0.
      p_index = p_index - 1.
    ENDIF.
  ENDIF.
ENDFORM.                               " GET_MARKED_ENTRY
*---------------------------------------------------------------------*
*       FORM NAECHSTER                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM naechster.
  DATA: last_list_pos LIKE sy-tabix, rc LIKE sy-subrc.
  IF status-action NE anzeigen AND status-action NE transportieren
  AND status-mode NE list_bild.
    PERFORM update_tab.
  ENDIF.
  IF <status>-mark_only = space.       "ufdetail
* jump to next entry
    nextline = nextline + 1.
    IF nextline GT maxlines.
      IF status-action NE hinzufuegen.
        nextline = maxlines.
        MESSAGE s008(sv).
        EXIT.
      ELSE.
        IF status-type EQ zweistufig AND
           status-mode EQ detail_bild.
          neuer = 'J'.
          MOVE <initial> TO <table1>.
          MOVE <table1> TO <vim_extract_struc>.
          IF x_header-bastab NE space AND x_header-texttbexst NE space.
            MOVE: <text_initial_x> TO <table1_xtext>,
                 <table1_xtext> TO <vim_xextract_text>.
*            MOVE: <text_initial_x> TO <table1_text>,
*                  <table1_text> TO <extract_text>.
          ENDIF.
          nextline = maxlines + 1.
        ELSE.
          nextline = nextline - 1.
          MESSAGE s008(sv).
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.                                "ufdetailb
* jump to next marked entry
    PERFORM get_marked_entry USING 'X'
                             CHANGING nextline
                                      rc.
    IF rc <> 0.
      MESSAGE s830(sv).
*   Letzter markierter Eintrag bereits erreicht.
      EXIT.
    ENDIF.
  ENDIF.                               "ufdetaile
  IF looplines = 0.
* coming from lower viewcluster-node
    l = nextline - firstline + 1.
    MOVE l TO <status>-cur_line.
  ELSEIF looplines = 1.
    firstline = l = 1.
    MOVE: firstline TO <status>-firstline,
          l         TO <status>-cur_line.
  ELSEIF looplines > 1.
    IF status-mode EQ detail_bild.
      last_list_pos = firstline + looplines - 1.
      IF nextline GT last_list_pos.
        IF <status>-mark_only = space. "ufdetail
          firstline = firstline + looplines - 1.
          l = 2.
        ELSE.                          "ufdetailb
          PERFORM get_page_and_position USING nextline
                                              looplines
                                        CHANGING firstline
                                                 l.
        ENDIF.                         "ufdetaile
        MOVE: firstline TO <status>-firstline,
              l         TO <status>-cur_line.
      ELSE.
        IF status-mode NE list_bild.
          l = nextline - firstline + 1.
          MOVE l TO <status>-cur_line.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "naechster
*&---------------------------------------------------------------------*
*&      Form  SET_MARK_ONLY
*&---------------------------------------------------------------------*
*       Sets status flag if entry with index p_index is marked.
*----------------------------------------------------------------------*
*      -->P_index  EXTRACT-index
*----------------------------------------------------------------------*
FORM set_mark_only USING    p_index LIKE sy-tabix.
  DATA: rc LIKE sy-subrc.
  PERFORM check_marked USING p_index
                       CHANGING rc.
  IF rc = 0.
    <status>-mark_only = 'X'.
  ENDIF.
ENDFORM.                               " SET_MARK_ONLY
*---------------------------------------------------------------------*
*       FORM PROCESS_DETAIL_SCREEN                                    *
*---------------------------------------------------------------------*
* process detail screen call                                          *
*---------------------------------------------------------------------*
* ---> MODE - C -> call mode (CALL SCREEN), S -> set mode (SET SCREEN)*
*---------------------------------------------------------------------*
FORM process_detail_screen USING value(mode) TYPE c.
  DATA: modulpool LIKE trdir-name,                          "#EC NEEDED
        no_input_happened(1) TYPE c,                       "#EC NEEDED
        state_action(1) TYPE c.                                  "#EC NEEDED
  IF detail NE '0000'.
    IF mode EQ 'S'.
      SET SCREEN detail.
      LEAVE SCREEN.
    ELSE.
      PERFORM vim_imp_call_screen USING detail.
    ENDIF.
  ELSE.
    RAISE detail_scr_nbr_missing.                           "#EC *
  ENDIF.
ENDFORM.                    "process_detail_screen
*---------------------------------------------------------------------*
*       FORM VORIGER                                                  *
*---------------------------------------------------------------------*
*       NEXTLINE:   Index of current entry in table EXTRACT
*       FIRSTLINE:  EXTRACT-index of first line shown on list screen
*       L:          Line number of list screen, where entry was chosen
*                   via F2
*       LOOPLINES:  Number of step loop lines in list screen
*---------------------------------------------------------------------*
FORM voriger.
  DATA: rc LIKE sy-subrc, n TYPE i.

  IF status-action NE anzeigen AND status-action NE transportieren
  AND status-mode NE list_bild.
    PERFORM update_tab.
  ENDIF.
  IF <status>-mark_only = space.       "ufdetail
* jump to previous entry
    nextline = nextline - 1.
    IF nextline LE 0.
      nextline = 1.
      MESSAGE s007(sv).
    ELSEIF nextline LT firstline.
* scroll upwards
      IF looplines > firstline.
* bumping into top of EXTRACT
        firstline = 1.
        l = nextline.
      ELSE.
        firstline = firstline - looplines + 1.
        l = looplines - 1.
      ENDIF.
      MOVE: firstline TO <status>-firstline,
           l         TO <status>-cur_line.
    ELSE.
      l = nextline - firstline + 1.
      MOVE l TO <status>-cur_line.
    ENDIF.
  ELSE.                                "ufdetailb
* jump to previous marked entry
    n = nextline DIV ( looplines - 1 ).
    PERFORM get_marked_entry USING space
                             CHANGING nextline rc.
    IF rc > 0.
      MESSAGE s831(sv).
*   Erster markierter Eintrag bereits erreicht.
    ELSE.
      IF nextline LT firstline.
        PERFORM get_page_and_position USING nextline
                                            looplines
                                      CHANGING firstline
                                               l.
        MOVE: firstline TO <status>-firstline,
              l         TO <status>-cur_line.
      ELSE.
        l = nextline - firstline + 1.
        MOVE l TO <status>-cur_line.
      ENDIF.
    ENDIF.
  ENDIF.                               "ufdetaile
ENDFORM.                    "voriger
*&---------------------------------------------------------------------*
*&      Form  CHECK_MARKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_INDEX  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM check_marked USING    p_index LIKE sy-tabix
                  CHANGING p_rc LIKE sy-subrc.

  p_rc = 4.
  READ TABLE extract INDEX p_index.                         "#EC *
  IF sy-subrc = 0 AND <xmark> = markiert. CLEAR p_rc. ENDIF.
ENDFORM.                               " CHECK_MARKED
*&---------------------------------------------------------------------*
*&      Form  GET_PAGE_AND_POSITION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LINE      line in EXTRACT
*      -->P_LOOPLINES # lines in list screen
*      <--P_FIRST     number of first line in list screen
*      <--P_PAGELINE  number of line no. P_LINE in list screen
*----------------------------------------------------------------------*
FORM get_page_and_position USING    p_line LIKE sy-tabix
                                    p_looplines LIKE sy-tabix
                           CHANGING p_first LIKE sy-tabix
                                    p_pageline LIKE sy-tabix.
  DATA: m TYPE i.
  m = p_line DIV ( p_looplines - 1 ).
  p_first = m * ( p_looplines - 1 ) + 1.
  p_pageline = p_line MOD ( p_looplines - 1 ).
ENDFORM.                               " GET_PAGE_AND_POSITION

*---------------------------------------------------------------------*
*       FORM  VIM_MODIFY_DETAIL_SCREEN                                *
*---------------------------------------------------------------------*
* Modifizieren der Screen-Attribute für das Detailbild                *
*---------------------------------------------------------------------*
FORM vim_modify_detail_screen.

  DATA: dummyflag TYPE xfeld.


* dataset locked by key-specific synchronizer lock?
  IF vim_sync_keyspec_check NE space.
    PERFORM check_sync_key_lock USING ' '
                                CHANGING vim_sync_key_lock.
  ENDIF.
  CLEAR vim_set_from_bc_pbo.
* dataset from BC-set? --> get field parameters
  IF replace_mode = space AND status-action = aendern
   AND vim_bc_chng_allowed = space.    "force changeability
    READ TABLE vim_bc_entry_list INTO vim_bc_entry_list_wa
     WITH TABLE KEY viewname = x_header-viewname
     keys = <vim_xextract_key>.
    IF sy-subrc = 0.
      vim_set_from_bc_pbo = 'X'.
    ENDIF.
  ENDIF.
  LOOP AT SCREEN.
    SPLIT screen-name AT '-' INTO vim_object vim_objfield. "Subviews ..
    IF status-action EQ anzeigen OR status-action EQ transportieren OR
       status-delete EQ geloescht.
      screen-input = '0'.
    ELSE.
      IF screen-group1 EQ 'KEY' AND screen-required NE 0 AND
         screen-input NE '0'.
        screen-input = '0'.
      ENDIF.
      IF status-action EQ hinzufuegen OR
         status-action EQ kopieren.
        IF neuer CO 'XJ' .
          IF screen-group1 EQ 'KEY'.
            IF ( vim_single_entry_function NE 'INS' OR
                 vim_single_entry_ins_key_input NE space ) AND
               ( x_header-existency NE 'M' OR
                 screen-name EQ vim_enddate_name ).
              screen-input = '1'.
            ENDIF.
            IF vim_single_entry_function EQ 'INS'.
              screen-request = '1'. sy-subrc = 8.
            ENDIF.
          ENDIF.
          IF vim_special_mode EQ vim_upgrade AND function NE 'DELE'.
            IF <status>-prof_found = vim_pr_into_view "UFprofiles begin
             AND screen-group1 = 'KEY'.
              PERFORM set_profile_key_attributes USING vim_objfield
                                                 CHANGING screen-input
                                                     vim_modify_screen.
              CLEAR vim_modify_screen.
            ENDIF.                     "UFprofiles end
            screen-request = '1'. sy-subrc = 8.
          ENDIF.
        ENDIF.
        IF vim_pr_activating <> space.
          IF screen-required = '1'.
* obligatory fields shall not stop profile import
            screen-required = '0'.     "UFprofile
          ENDIF.
        ENDIF.
      ELSE.
        IF replace_mode NE space.
          CASE vim_special_mode.
            WHEN vim_replace.
              IF screen-name EQ sel_field_for_replace_l.
                screen-request = '1'. sy-subrc = 8.
                IF screen-invisible = '1'.
                  screen-input = '1'.
                ENDIF.
              ENDIF.
            WHEN vim_upgrade.
              IF NOT function IN exted_functions.
                screen-request = '1'. sy-subrc = 8.
              ENDIF.
*             screen-input = '1'.
          ENDCASE.
        ELSE.
          IF vim_special_mode EQ vim_delete.
            screen-input = '0'.
          ENDIF.
          IF x_header-delmdtflag NE space AND
             x_header-existency EQ 'U' AND
             screen-name EQ vim_begdate_name.
            screen-input = '0'.
          ENDIF.
        ENDIF.
        IF status-action = aendern AND neuer <> 'J'.
* Dataset locked by key-specific synchronizer lock?
          IF vim_sync_key_lock NE space AND screen-group1 <> 'KEY' AND
                                            screen-name NE 'VIM_MARKED'.
            screen-input = 0.
            vim_modify_screen  = 'X'.
          ENDIF.
          IF vim_set_from_bc_pbo <> space.
* Dataset comes from BC-set -> check field parameter
            PERFORM vim_bc_logs_use USING    vim_objfield
                                             vim_bc_entry_list_wa
                                    CHANGING screen
                                             dummyflag.
          ENDIF.
        ENDIF.
      ENDIF. "status-action EQ hinzufuegen OR status-action EQ kopieren.
    ENDIF.
    IF <xmark> EQ markiert AND <status>-mark_only = space. "ufdetail
      screen-intensified = '1'.
    ENDIF.
    IF vim_objfield <> space AND vim_object = x_header-maintview.
      LOOP AT x_namtab WHERE viewfield = vim_objfield AND
                             ( texttabfld = space OR keyflag = space )."#EC *
        IF x_namtab-readonly = vim_hidden.
          screen-active = '0'.
        ELSEIF x_namtab-readonly = rdonly.
          screen-input = '0'.
        ENDIF.
        EXIT.
      ENDLOOP.
    ENDIF.                                   ".. Subviews
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                               "vim_modify_detail_screen

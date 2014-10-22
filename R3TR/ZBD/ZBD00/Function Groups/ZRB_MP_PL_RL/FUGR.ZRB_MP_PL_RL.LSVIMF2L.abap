*---------------------------------------------------------------------*
*       FORM CALL_DYNPRO                                              *
*---------------------------------------------------------------------*
*       UF170200: transp. mode: don't fill CORR_KEYTAB-TABKEY with
*                 more than 120 chars
*
*---------------------------------------------------------------------*
FORM call_dynpro.
  DATA: state_init TYPE c, rc LIKE sy-subrc,
        dpl_sel_entries TYPE i, cd_specmode_safe(1) TYPE c,
        addr_e071k LIKE e071k, cd_addr_71ktab LIKE e071k OCCURS 0,
        object_key TYPE ad_objkey,
        max_trsp_keylength_in_byte TYPE i,
*       viewcluster dequeue flag XB H626152
        f_return(1) TYPE c.

  FIELD-SYMBOLS: <object_keyx> TYPE x.

  max_trsp_keylength_in_byte = vim_max_trsp_keylength
   * cl_abap_char_utilities=>charsize.
  CASE vim_adjust_middle_level_mode.
    WHEN space.
    WHEN subset OR 'X'.
      vim_special_mode = vim_direct_upgrade.
      IF vim_adjust_middle_level_mode EQ subset.
        x_namtab[] = vim_adj_namtab.
      ENDIF.
    WHEN 'L'.
      CLEAR vim_adjust_middle_level_mode. function = 'ENDE'.
      EXIT.
  ENDCASE.
* IF <STATUS>-ALR_SETUP EQ SPACE.
  IF <status>-initializd EQ space.
    PERFORM init_state_vector.
  ENDIF.
  DESCRIBE TABLE dpl_sellist LINES dpl_sel_entries.
  IF x_header-selection EQ space.
    IF dpl_sel_entries GT 0.
      MOVE 'X' TO x_header-selection.
      MODIFY x_header INDEX 1.
      ASSIGN dpl_sellist-*sys* TO <vim_ck_sellist>.
    ELSE.
      DESCRIBE TABLE dba_sellist.
      IF sy-tfill GT 0.
        MOVE 'X' TO x_header-selection.
        MODIFY x_header INDEX 1.
*       ASSIGN DBA_SELLIST-*SYS* TO <VIM_CK_SELLIST>.
      ENDIF.
      ASSIGN dba_sellist-*sys* TO <vim_ck_sellist>.
    ENDIF.
  ELSE.
    IF dpl_sel_entries GT 0.
      ASSIGN dpl_sellist-*sys* TO <vim_ck_sellist>.
    ELSE.
      ASSIGN dba_sellist-*sys* TO <vim_ck_sellist>.
    ENDIF.
  ENDIF.
  PERFORM vim_maint_selflag USING 'I'
                            CHANGING x_header-selection.
* Übergangslösung Sortierungsproblem Anfang
  IF <status>-alr_sorted EQ space.
    SORT total BY <vim_xtotal_key>.
    MOVE 'X' TO <status>-alr_sorted.
  ENDIF.
* Übergangslösung Sortierungsproblem Ende
  PERFORM exclude_cua_functions.
  IF x_header-frm_on_aut NE space AND  "4.5a: support indiv. auth. chck
     <status>-auth_check NE space.     "auth check is requested
    vim_auth_action = view_action.
    vim_auth_event = vim_auth_requested_check.
    ASSIGN <vim_ck_sellist> TO <vim_auth_sellist>.
    PERFORM (x_header-frm_on_aut) IN PROGRAM.
    IF vim_auth_rc NE 0.
      PERFORM vim_process_message USING vim_auth_msgid 'I' 'E'
                                        vim_auth_msgno
                                        vim_auth_msgv1 vim_auth_msgv2
                                        vim_auth_msgv3 vim_auth_msgv4.
      CASE vim_auth_rc.
        WHEN 4.                        "show only
          maint_mode = anzeigen.
          excl_cua_funct-function = 'AEND'. COLLECT excl_cua_funct.
        WHEN 8.                        "exit
          RAISE missing_corr_number.
      ENDCASE.
    ENDIF.
  ENDIF.
  IF maint_mode NE anzeigen AND maint_mode NE transportieren AND
     <status>-dlclalrckd EQ space.
    IF vim_system_type NE 'SAP' AND
       x_header-customauth CO sap_only_classes.
*     MESSAGE I137(SV). "keine Ãnderungen, Daten gehören SAP
      PERFORM vim_process_message USING 'SV' 'I' 'I' '137'
                                         space space space space.
    ENDIF.
    MOVE 'X' TO <status>-dlclalrckd.
  ENDIF.
  IF x_header-subsetflag NE space AND <status>-sbsid_rcvd CO ' R'.
    PERFORM init_subset_keyfields.
  ENDIF.
  IF x_header-selection NE space AND <status>-selcd_rcvd EQ space.
    LOOP AT dpl_sellist WHERE ddic EQ space OR ( operator EQ 'GE' OR
                                                 operator EQ 'GT' OR
                                                 operator EQ 'LE' OR
                                                 operator EQ 'LT' ).
      MOVE 'X' TO state_init.
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0. "no entries in DPL_SELLIST -> all entries req.
      DESCRIBE TABLE total.
      IF <status>-maxlines NE sy-tfill AND  "missing entries in EXTRACT
         <status>-st_data EQ gesamtdaten.   "and no selection made
        IF x_header-delmdtflag NE space.
*         DESCRIBE TABLE VIM_COLLAPSED_MAINKEYS. "SW int.M. 1599934/1999
*         IF <STATUS>-MAXLINES NE SY-TFILL."missing entries in EXTRACT
          IF <status>-maxlines = 0.    "SW int.M. 1599934/1999
            MOVE 'X' TO state_init.
          ENDIF.
        ELSE.
          MOVE 'X' TO state_init.
        ENDIF.
      ENDIF.
    ENDIF.
    IF state_init NE space.
      CLEAR: <status>-maxlines,
             <status>-cur_field,
             <status>-cur_offset.
      MOVE: 1 TO <status>-cur_line,
            1 TO <status>-firstline,
            nicht_geloescht TO <status>-st_delete,
            maint_mode TO <status>-st_action,
            list_bild TO <status>-st_mode.
      PERFORM set_status_nokeyselcnds.
    ENDIF.
    MOVE 'X' TO <status>-selcd_rcvd.
  ENDIF.
  IF <status>-initializd EQ 'x'.
    PERFORM set_status_nokeyselcnds.
  ENDIF.
  IF maint_mode NE anzeigen AND
     corr_nbr NE space AND corr_nbr NE <status>-corr_nbr.
    MOVE: <status>-corr_nbr TO <status>-l_corr_nbr,
          corr_nbr TO <status>-corr_nbr.
  ENDIF.
  IF maint_mode EQ transportieren.
    PERFORM request_corr_number.
    IF x_header-flag EQ vim_transport_denied.
      MESSAGE i142(sv).
      function = ucomm = end. EXIT.
    ENDIF.
  ELSEIF maint_mode EQ aendern.
    PERFORM check_transp_objs_for_maint USING rc.
    CASE rc.
      WHEN 4.
        maint_mode = anzeigen.
        excl_cua_funct-function = 'AEND'. COLLECT excl_cua_funct.
*       viewcluster dequeue flag XB H626152B
*        maint_mode = aendern.
        function = ucomm = 'ANZG'.
*        f_return = 'X'.
        f_return = ' '.
*       viewcluster dequeue flag XB H626152E
      WHEN 8.
        RAISE missing_corr_number.
    ENDCASE.
  ELSE.
    vim_client_state = vim_noact.
  ENDIF.
  IF f_return <> 'X'.
    MOVE: maint_mode          TO status-action,
          <status>-st_delete  TO status-delete,
          <status>-st_data    TO status-data,
          <status>-title      TO title,
          <status>-firstline  TO firstline,
          <status>-mk_xt      TO mark_extract,
          <status>-mk_to      TO mark_total,
          <status>-cur_line   TO l,
          <status>-cur_field  TO f,
          <status>-cur_offset TO o,
          <status>-maxlines   TO maxlines,
          maint_mode          TO title-action,
          firstline           TO nextline.
    IF status-action EQ aendern AND "ignore history when mode was chngd.
       <status>-st_action EQ hinzufuegen.
      MOVE: <status>-st_action TO status-action,
            <status>-st_action TO title-action.
    ENDIF.
    IF <status>-st_delete EQ geloescht.
      DESCRIBE TABLE extract LINES maxlines.
      IF maxlines EQ 0.
        CLEAR status-delete.
        MOVE list_bild TO <status>-st_mode.
      ENDIF.
    ELSEIF <status>-st_mode = detail_bild"SW (1248405/98) ..
       AND <status>-st_action <> hinzufuegen.
      DESCRIBE TABLE extract LINES maxlines.
      IF maxlines EQ 0.
        MOVE list_bild TO <status>-st_mode.
*    nur ein Eintrag  -> automatisch wieder auf Detailbild verzweigt
*    mehrere Einträge -> Listbild, da kein Eintrag ausgezeichnet
      ENDIF.                             ".. SW
    ENDIF.
    IF ( status-action EQ transportieren AND
                                                            "UF28042000
        <status>-l_corr_nbr NE <status>-corr_nbr )
     OR ( vim_client_state EQ vim_log AND 'ST' NS status-action ) .
      PERFORM prepare_corr.
    ENDIF.
    IF status-action EQ transportieren AND get_corr_keytab NE space.
      PERFORM get_keytab.
    ENDIF.
    IF status-action EQ transportieren AND <status>-crcntsknwn EQ space.
      LOOP AT vim_addr_e071k_tab INTO addr_e071k.
        addr_e071k-trkorr = <status>-corr_nbr.
        MODIFY vim_addr_e071k_tab FROM addr_e071k.
      ENDLOOP.
      LOOP AT total.    "note entries already contained in CORR_KEYTAB
        MOVE <vim_total_struc> TO <table1>.
        IF x_header-bastab EQ space.     "view
          PERFORM (corr_formname) IN PROGRAM (sy-repid)
                                  USING pruefen rc.
        ELSE.                            "base table
          corr_keytab =  e071k.
          corr_keytab-objname = x_header-maintview.
          IF x_header-keylen GT max_trsp_keylength_in_byte.
*        IF x_header-keylen GT vim_max_trsp_keylength.     "UF170200b
            MOVE <vim_xtotal_key> TO <vim_corr_keyx>(x_header-maxtrkeyln).
*          MOVE total TO corr_keytab-tabkey(x_header-maxtrkeyln).
          ELSE.                                             "UF170200e
            MOVE <vim_xtotal_key> TO <vim_corr_keyx>(x_header-keylen).
*          MOVE total TO corr_keytab-tabkey(x_header-keylen).
          ENDIF.                                            "UF170200
          PERFORM update_corr_keytab USING pruefen rc.
          IF rc EQ 0.
            IF x_header-texttbexst NE space AND  "text table
               <vim_xtotal_text> NE <text_initial_x>.
*             <total_text> NE <text_initial>.
              corr_keytab =  e071k.
              corr_keytab-objname = x_header-texttab.
              IF x_header-textkeylen GT max_trsp_keylength_in_byte.
*           IF x_header-textkeylen GT vim_max_trsp_keylength. "UF170200b
                MOVE <vim_xtotal_text> TO
                               <vim_corr_keyx>(x_header-maxtrkeyln).
*              MOVE <total_text> TO
*                             corr_keytab-tabkey(x_header-maxtrtxkln).
              ELSE.                                         "UF170200e
                MOVE <vim_xtotal_text> TO
                               <vim_corr_keyx>(x_header-textkeylen).
*              MOVE <total_text> TO
*                             corr_keytab-tabkey(x_header-textkeylen).
              ENDIF.                                        "UF170200
              PERFORM update_corr_keytab USING pruefen rc.
            ENDIF.
          ENDIF.
        ENDIF.
        IF rc = 0 AND x_header-texttbexst <> space AND "SW Texttransl ..
          vim_texttab_is_ro EQ space.
          PERFORM vim_text_keytab_entry USING <vim_xtotal_key> pruefen rc.
        ENDIF.                           ".. Texttransl
        IF rc EQ 0.
          MOVE transportieren TO <action>.
          IF x_header-adrnbrflag EQ 'O' AND <address_number> NE space.
            PERFORM vim_address_keytab_entries USING pruefen rc.
          ELSEIF x_header-adrnbrflag EQ 'N' AND <address_number> NE space.
            APPEND LINES OF vim_addr_e071k_tab TO cd_addr_71ktab.
            ASSIGN object_key TO <object_keyx> CASTING.
            MOVE <vim_xtotal_key> TO <object_keyx>(x_header-keylen).
*          object_key = <vim_total_key>.
            CALL FUNCTION 'ADDR_TRANSPORT_ENTRIES'
              EXPORTING
                addrnumber = <address_number>
                table_name = vim_addr_basetable
                field_name = vim_addr_bastab_field
                objkey     = object_key
              TABLES
                e071k_tab  = cd_addr_71ktab.
            vim_exit_11_12_active = 'X'.
            LOOP AT cd_addr_71ktab INTO corr_keytab WHERE
             mastername = vim_addr_e071k_master_46 OR    "UF688403/2000
             mastername = vim_addr_e071k_master.
* Rel < 4.6A: ignore old type address entries inserted only for downward
*             compatibility
              PERFORM update_corr_keytab USING pruefen rc.
              IF rc NE 0. EXIT. ENDIF.
            ENDLOOP.
            CLEAR vim_exit_11_12_active.
            REFRESH cd_addr_71ktab.
          ENDIF.
          IF rc EQ 0.
            IF x_header-frm_e071ks NE space.
              vim_exit_11_12_active = 'X'.
              MOVE pruefen TO corr_action.
              PERFORM (x_header-frm_e071ks) IN PROGRAM (sy-repid).
              IF sy-subrc NE 0. CLEAR <action>. ENDIF.
              CLEAR vim_exit_11_12_active.
            ENDIF.
          ELSE.
            CLEAR <action>.
          ENDIF.
        ELSE.
          CLEAR <action>.
        ENDIF.
        IF maxlines GT 0 AND
           vim_special_mode NE vim_extedit.                "SW 1.4.1998
          READ TABLE extract WITH KEY <f1_x>."#EC *
          IF sy-subrc EQ 0.
            MOVE: <mark> TO <xmark>, <action> TO <xact>.
            MODIFY extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        MODIFY total.
      ENDLOOP.
      MOVE 'X' TO <status>-crcntsknwn.
    ENDIF.
    IF vim_restore_mode NE space.
      status-mode = <status>-st_mode.
      CLEAR vim_restore_mode.
      EXIT.
    ENDIF.
    IF vim_special_mode NE vim_extedit.
      CASE vim_single_entry_function.
        WHEN space OR 'UPD' OR 'SHOW'.
          IF <status>-st_mode EQ detail_bild.
            MOVE: 'DETA' TO function,
                  nextline TO firstline.
            IF old_nl NE 0.                                 "GKPR - 0001009660
              nextline = old_nl.                            "GKPR - 0001009660
              CLEAR old_nl.                                 "GKPR - 0001009660
            ELSE.                                           "GKPR - 0001009660
              nextline = firstline + l - 1.
            ENDIF.                                          "GKPR - 0001009660
            DESCRIBE TABLE extract LINES maxlines.
            IF maxlines EQ 0.
              IF <status>-st_action EQ hinzufuegen.
                neuer = 'J'.
              ELSE.
                PERFORM fill_extract.
              ENDIF.
            ENDIF.
*         CALL SCREEN DETAIL.
            PERFORM process_detail_screen USING 'C'.
          ELSE.
            CALL SCREEN liste.
          ENDIF.
        WHEN 'INS'.
          function = 'NEWL'. PERFORM hinzufuegen.
        WHEN 'DEL'.
          cd_specmode_safe = vim_special_mode.
          vim_special_mode = vim_extedit.
          READ TABLE total INTO extract INDEX 1. <xact> = geloescht.
          APPEND extract.
          PERFORM vim_external_edit.
          vim_special_mode = cd_specmode_safe.
          excl_cua_funct-function = 'UNDO'. COLLECT excl_cua_funct.
          PERFORM selektiere USING geloescht.
      ENDCASE.
      MOVE: function TO ucomm.
* only relevant in viewcluster(navigation from detail screen):
      IF status-mode = detail_bild.
        last_act_entry = nextline.
      ELSE.
* navigation in viewcluster by tree-control: unuseable
        last_act_entry = <status>-firstline + <status>-cur_line - 1.
      ENDIF.
    ELSE.                                "ext. edit.
      PERFORM vim_external_edit.
      <status>-maxlines = 0.             "SW  int. Meldung 519239/1999
    ENDIF.
  ENDIF.
  IF function NE 'ORGD' AND function NE 'ORGL' AND
     function NE 'SAVE' AND function NE 'TRSP' AND function NE 'TRAE'.
    IF x_header-subsetflag NE space AND <status>-sbsid_rcvd NE 'S'.
      CLEAR <status>-sbsid_rcvd.
    ENDIF.
*   ELSEIF X_HEADER-SUBSETFLAG EQ SPACE AND
    IF x_header-selection NE space AND
       <status>-selcd_rcvd NE space.
      CLEAR <status>-selcd_rcvd.
    ENDIF.
    IF x_header-delmdtflag NE space.
      EXPORT vim_collapsed_mainkeys TO MEMORY ID vim_memory_id_1.
    ENDIF.
    ASSIGN dba_sellist-*sys* TO <vim_sellist>.
    vim_enqueue_range = x_header-subsetflag.
  ENDIF.
* MPRE 13.11.2088    1274142
  " Non key fields of the view are hidden OR read only OR
  " removed from screen manually, update flag is not set => activation
  " links are not updated during BC Set activation
  " To update activtion links, set update flag => calls after_save module.
  " activation links are updated.
  IF vim_import_profile NE space AND
    VIM_SPECIAL_MODE = 'E' AND
     NOT imp_results[] IS INITIAL AND
    ( vim_results_of_ext_mod-nbr_of_udl NE 0 OR
     vim_results_of_ext_mod-nbr_of_ins NE 0 OR
     vim_results_of_ext_mod-nbr_of_del NE 0 OR
     vim_results_of_ext_mod-nbr_of_upd NE 0 ).
    IF <status>-upd_flag EQ space.
      <status>-upd_flag = 'X'.
    ENDIF.
  ENDIF.
* MPRE 13.11.2088    1274142
ENDFORM.                    "call_dynpro

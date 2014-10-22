*&--------------------------------------------------------------------*
*&      Form UPGRADE                                                  *
*&--------------------------------------------------------------------*
* process upgrade                                                     *
*---------------------------------------------------------------------*
* U_MODE --> ' ' - client 000, 'O' - other client, others - remote sys*
*---------------------------------------------------------------------*
FORM upgrade USING value(u_mode) TYPE c.
  DATA: u_kind, u_update_happened, trans_pattern(8) TYPE c,   "#EC NEEDED
        hf TYPE i, u_client LIKE sy-mandt, u_tabind LIKE sy-tabix,   "#EC NEEDED
        u_it000 LIKE vim_t000 OCCURS 10, u_title(40) TYPE c,         "#EC NEEDED
        u_remote_sys LIKE rfcdes-rfcdest, u_t000 LIKE vim_t000,      "#EC NEEDED
        u_counter TYPE i, u_del_cnt TYPE i, u_rc TYPE i, hf1 TYPE i,
        u_funcsafe(4) TYPE c, u_txt_fu_beg TYPE i, u_txt_fu_lg TYPE i,  "#EC NEEDED
        u_newversion(1) TYPE c VALUE 'X', u_mark_entries(1) TYPE c,     "#EC NEEDED
        u_action(1) TYPE c, u_specmode_safe(1) TYPE c,               "#EC NEEDED
        u_called_from(1) TYPE c, u_oc_exst LIKE ntab_cmp-flag,
        u_sellist TYPE vimsellist_type, sellines TYPE i.
  CONSTANTS: u_text_frm(30) TYPE c VALUE 'FILL_TEXTTAB_KEY'.             "#EC NEEDED
  FIELD-SYMBOLS: <u_f1> TYPE x, <u_sellist> TYPE vimsellist_type,
                 <w_sellist> TYPE vimsellist.

* data and field symbols for copying the extract to and from
* the compare tool container:
  DATA:
    cmp_container_ref    TYPE REF TO data,
    cmp_container_wa_ref TYPE REF TO data,
    extract_len          TYPE i,
    subrc_buf            TYPE sy-subrc.
  FIELD-SYMBOLS:
    <cmp_cont>    TYPE STANDARD TABLE,
    <cmp_cont_wa> TYPE ANY,
    <x_dummy>     TYPE x.

  READ TABLE excl_cua_funct WITH KEY function = 'CMPR'.
  IF sy-subrc EQ 0.                    "upgrade is not allowed
    MESSAGE s001(sv).
    EXIT.
  ENDIF.
* upgrade with client 0 only if current client <> 000
* upgrade with other clients only if objects are clientdependent
  IF u_mode EQ space AND sy-mandt EQ '000' OR  "upgrade with client 000
     ( u_mode EQ space OR u_mode EQ 'O' ) AND
     x_header-clidep EQ space.
    MESSAGE s001(sv).
    EXIT.
  ENDIF.
* send warning if address number could be changed
  IF status-action EQ aendern AND
   ( x_header-adrnbrflag NE space AND x_header-adrnbrflag <> 'N' ).
    PERFORM set_pf_status USING 'ERROR'.
    MESSAGE i139(sv). "Adreßdaten werden nicht übernommen
    PERFORM set_pf_status USING status.
  ENDIF.
  CLEAR: u_client, u_remote_sys.
  IF u_mode EQ space.
    u_client = '000'.
  ELSEIF u_mode EQ 'O'.
    IF vim_default_upgr_clnt-client NE space AND
       vim_default_upgr_clnt-viewname EQ x_header-viewname.
      u_client = vim_default_upgr_clnt-client.
    ENDIF.
  ELSE.
    IF vim_default_rfc_dest-rfcdest NE space AND
       vim_default_rfc_dest-viewname EQ x_header-viewname.
      u_remote_sys = vim_default_rfc_dest-rfcdest.
    ENDIF.
  ENDIF.
  IF vim_special_mode EQ vim_direct_upgrade.
    function = 'ABR'.                  "avoid processing detail screen
    PERFORM fill_extract. CLEAR function.
    u_specmode_safe = vim_special_mode.
    ASSIGN dba_sellist[] TO <u_sellist>.
  ELSE.
    ASSIGN <vim_ck_sellist> TO <u_sellist>.
  ENDIF.
  vim_special_mode = vim_upgrade.
  MOVE: geloescht TO trans_pattern, aendern TO trans_pattern+1(1),
        neuer_geloescht TO trans_pattern+2(1),
        neuer_eintrag   TO trans_pattern+3(1),
        update_geloescht TO trans_pattern+4(1),
        aendern         TO trans_pattern+5(1),
        original  TO trans_pattern+6(1),
        aendern TO trans_pattern+7(1).
  IF x_header-bastab EQ space.         "view
    u_kind = 'V'.
  ELSE.
    IF x_header-texttbexst EQ space.   "base table
      u_kind = 'T'.
    ELSE.                              "base table with text table
      u_kind = 'X'.
    ENDIF.
  ENDIF.

* Add collapsed or merged timedep. entries
  IF x_header-delmdtflag NE space.
    DESCRIBE TABLE vim_collapsed_mainkeys LINES hf.
    DESCRIBE TABLE vim_merged_entries.
    IF sy-tfill GT 0 OR hf GT 0.
      vim_ignore_collapsed_mainkeys = 'X'.
      PERFORM fill_extract.
      CLEAR vim_ignore_collapsed_mainkeys.
    ENDIF.
  ENDIF.
  IF ( vim_system_type NE 'SAP' AND sy-mandt EQ '000' )
   OR x_header-importable = vim_not_importable.
    u_action = anzeigen.
  ELSE.
    u_action = status-action.
  ENDIF.
  TRANSLATE u_action USING 'SCUA'.
  IF vim_adjust_middle_level_mode NE space.
    TRANSLATE u_action USING 'Aa'.
  ENDIF.
  u_called_from = vim_special_adjust_mode.
  TRANSLATE u_called_from USING ' VSFXF'.
  IF NOT vim_oc_inst IS INITIAL.
* data access restricted?
    IF ( u_action = 'C'
         AND NOT vim_oc_inst->oc_selcrit_read_tab IS INITIAL )
     OR ( 'Aa' CS u_action
          AND NOT vim_oc_inst->oc_selcrit_maint_tab IS INITIAL ).
      u_oc_exst = 'X'.
    ENDIF.
  ENDIF.
  APPEND LINES OF <u_sellist> TO u_sellist.
  DELETE u_sellist WHERE from_auth <> space
   AND ddic <> 'S' AND ddic <> 'B'.
  IF sy-subrc = 0.
    DESCRIBE TABLE u_sellist LINES sellines.
    IF sellines GT 0.
      READ TABLE u_sellist INDEX sellines ASSIGNING <w_sellist>.
      CLEAR <w_sellist>-and_or.
    ENDIF.
  ENDIF.

* copy extract to compare tool container
  DESCRIBE FIELD extract LENGTH extract_len IN BYTE MODE.
  IF extract_len <= 64.
    CREATE DATA cmp_container_ref TYPE TABLE OF tbl64.
    ASSIGN cmp_container_ref->* TO <cmp_cont>.
    CREATE DATA cmp_container_wa_ref TYPE tbl64.
    ASSIGN cmp_container_wa_ref->* TO <cmp_cont_wa>.
  ELSEIF extract_len <= 256.
    CREATE DATA cmp_container_ref TYPE TABLE OF tbl256.
    ASSIGN cmp_container_ref->* TO <cmp_cont>.
    CREATE DATA cmp_container_wa_ref TYPE tbl256.
    ASSIGN cmp_container_wa_ref->* TO <cmp_cont_wa>.
  ELSEIF extract_len <= 1024.
    CREATE DATA cmp_container_ref TYPE TABLE OF tbl1024.
    ASSIGN cmp_container_ref->* TO <cmp_cont>.
    CREATE DATA cmp_container_wa_ref TYPE tbl1024.
    ASSIGN cmp_container_wa_ref->* TO <cmp_cont_wa>.
  ELSEIF extract_len <= 4096.
    CREATE DATA cmp_container_ref TYPE TABLE OF tbl4096.
    ASSIGN cmp_container_ref->* TO <cmp_cont>.
    CREATE DATA cmp_container_wa_ref TYPE tbl4096.
    ASSIGN cmp_container_wa_ref->* TO <cmp_cont_wa>.
  ELSEif extract_len <= 8192.
    CREATE DATA cmp_container_ref TYPE TABLE OF tbl8192.
    ASSIGN cmp_container_ref->* TO <cmp_cont>.
    CREATE DATA cmp_container_wa_ref TYPE tbl8192.
    ASSIGN cmp_container_wa_ref->* TO <cmp_cont_wa>.
  else.
    CREATE DATA cmp_container_ref TYPE TABLE OF tbl32000.
    ASSIGN cmp_container_ref->* TO <cmp_cont>.
    CREATE DATA cmp_container_wa_ref TYPE tbl32000.
    ASSIGN cmp_container_wa_ref->* TO <cmp_cont_wa>.
  ENDIF.

  ASSIGN <cmp_cont_wa> TO <x_dummy> CASTING.
  LOOP AT extract.
    CLEAR <x_dummy>.
    <x_dummy> = <vim_xextract>.
    APPEND <cmp_cont_wa> TO <cmp_cont>.
  ENDLOOP.

  CALL FUNCTION 'SCT1_VIEW_COMPARE_AND_ADJUST'
       EXPORTING
            iv_view_name              = x_header-maintview  "VIEWNAME
*             IV_VIEW_VARIANT    =
            iv_kind                   = u_kind
            iv_mode                   = u_action
*             IV_LANGUAGE        = SY-LANGU
*             IV_CLIENT_REMOTE   = U_CLIENT
            iv_rfc_destination        = u_remote_sys
            iv_called_from            = u_called_from
            iv_data_access_restricted = u_oc_exst
       IMPORTING
            ev_update          = u_update_happened
            ev_mark_entries    = u_mark_entries
       TABLES
            it_header          = x_header
            it_namtab          = x_namtab
            it_sellist         = u_sellist
            ct_box             = <cmp_cont>
       EXCEPTIONS
            canceled           = 1
            wrong_parameter    = 2
            compare_error      = 3
            OTHERS             = 4.
  subrc_buf = sy-subrc.

* copy compare tool container back to extract
  REFRESH extract.
  LOOP AT <cmp_cont> ASSIGNING <cmp_cont_wa>.
    ASSIGN <cmp_cont_wa> TO <x_dummy> CASTING.
    <vim_xextract> = <x_dummy>(extract_len).
    APPEND extract.
  ENDLOOP.

  sy-subrc = subrc_buf.
  IF sy-subrc GT 01.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    MESSAGE s135(sv). sy-subrc = 01.
  ENDIF.
  IF status-action EQ anzeigen AND u_update_happened NE space.
    sy-subrc = 1.
  ENDIF.
  CASE sy-subrc.
    WHEN 0.
      IF u_update_happened NE space.
* transfer changed entries from EXTRACT into TOTAL
        CLEAR: u_counter, u_del_cnt. replace_mode = 'X'.
        DESCRIBE TABLE extract LINES maxlines.
* 1st: handle deleted entries
        LOOP AT extract.
          IF <xact> EQ original.
            DELETE extract. CONTINUE.
          ENDIF.
          CHECK <xact> EQ geloescht OR <xact> EQ neuer_geloescht OR
                <xact> EQ update_geloescht.
          hf = sy-tabix.
          READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
* Condition Redundant - Internal Message  0001699060 - ACHACHADI
*          IF sy-subrc NE 0 OR ( sy-subrc EQ 0 AND  "#EC BOOL_OK
          IF <action> EQ <xact> .
            DELETE extract. CONTINUE.
          ENDIF.
          <mark> = markiert. ADD 1 TO mark_total.
          MODIFY total INDEX sy-tabix.
          <xmark> = markiert. ADD 1 TO mark_extract.
          MODIFY extract.
          IF vim_special_adjust_mode EQ subset.
            PERFORM vim_restore_subset_conds.
          ENDIF.
          PERFORM vim_process_view_entry USING hf 'DELE' u_rc.
          CHECK u_rc NE 4.
          IF u_rc EQ 8.
            EXIT.
          ENDIF.
          ADD: counter TO u_del_cnt, 1 TO u_counter.
        ENDLOOP.
        IF u_counter GT u_del_cnt.
          SUBTRACT u_del_cnt FROM u_counter.
          MESSAGE i116(sv) WITH u_counter. "& Einträge konnten nicht g
        ENDIF.
        CLEAR u_counter.
        IF status-type EQ einstufig.
          CLEAR: ok_code, function.
        ELSE.
          function = ok_code = 'COMP'.
        ENDIF.
* 2nd: handle changed entries
        ASSIGN <vim_xtotal>(x_header-tablen) TO <u_f1>.
        LOOP AT extract.
          IF <xact> NE aendern AND <xact> NE neuer_eintrag.
            DELETE extract. CONTINUE.
          ENDIF.
          hf = sy-tabix.
          READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
          IF sy-subrc EQ 0.            "entry exists in current client
            IF extract EQ total. "no changes -> delete and continue
              DELETE extract. CONTINUE.
            ELSEIF <xact> EQ neuer_eintrag AND "new entry exists and
                <action> EQ geloescht OR <action> EQ neuer_geloescht OR
                 <action> EQ update_geloescht."entry deleted in cur clnt
              status-delete = geloescht. " -> first undelete it
              <xact> = <action>. MODIFY extract. u_funcsafe = function.
              IF vim_special_adjust_mode EQ subset.
                PERFORM vim_restore_subset_conds.
              ENDIF.
              PERFORM vim_mark_and_process USING hf 'UNDO' hf1 u_rc.
              CLEAR status-delete. function = u_funcsafe.
              vim_special_mode = vim_upgrade.
              CHECK u_rc NE 4.
              IF u_rc EQ 8.
                EXIT.
              ENDIF.
              READ TABLE extract INDEX hf.
              READ TABLE total WITH KEY <vim_xextract_key>  "#EC *
                                                      BINARY SEARCH.
              IF <u_f1> EQ <table2_x>.   "no changes after undo
                DELETE extract. CONTINUE."delete & continue
              ELSE.
                <xact> = aendern. MODIFY extract.
              ENDIF.
            ELSEIF <u_f1> EQ <table2_x>. "no changes -> delete and cont
              DELETE extract. CONTINUE.
            ELSEIF <xact> EQ neuer_eintrag AND <action> EQ original.
              <xact> = aendern. MODIFY extract.
            ENDIF.
          ENDIF.                       "sy-subrc eq 0.
          IF vim_special_adjust_mode EQ subset.
            PERFORM vim_restore_subset_conds.
          ENDIF.
          PERFORM vim_modify_view_entry USING hf u_rc.
          CHECK u_rc NE 4.
          IF u_rc EQ 8.
            EXIT.
          ENDIF.
          IF u_mark_entries NE space.  "mark ajusted entries
            READ TABLE total WITH KEY <vim_xtotal_key> BINARY SEARCH  "#EC *
                             TRANSPORTING NO FIELDS.
            IF <mark> EQ nicht_markiert.
              <mark> = markiert. ADD 1 TO mark_total.
              MODIFY total INDEX sy-tabix.
              ADD 1 TO mark_extract.
            ENDIF.
          ENDIF.
          extract = total.
          MODIFY extract.
          ADD 1 TO u_counter.
        ENDLOOP.
        IF temporal_delimitation_happened NE space.
          REFRESH vim_delim_entries.
          CLEAR temporal_delimitation_happened.
        ENDIF.
        status-data = title-data = auswahldaten.
        nextline = l = 1.
        IF u_del_cnt NE 0 AND u_counter NE 0.
          MESSAGE s140(sv) "&1 Einträge geloescht, &2 Einträge übernom
            WITH u_del_cnt u_counter.
        ELSEIF u_del_cnt NE 0.
          MESSAGE s011(sv) WITH u_del_cnt. "Anzahl gelöschter Einträge
        ELSE.
          MESSAGE s012(sv) WITH u_counter. "Anzahl veränderter Einträg
        ENDIF.
        CLEAR replace_mode.
      ELSE.                            "no update happened
        IF x_header-delmdtflag NE space.
          PERFORM fill_extract. "consider collapsed or merged entries
        ENDIF.
      ENDIF.                           "u_update_happend ne space
      DESCRIBE TABLE extract LINES maxlines.
      nextline = 1.
      IF vim_special_adjust_mode NE space.
        CLEAR: vim_special_mode, vim_special_adjust_mode,
               <status>-upd_flag, maxlines, <status>-maxlines.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        IF vim_adjust_middle_level_mode NE space.
          function = 'SAVE'.
        ENDIF.
      ENDIF.
    WHEN 1. "ignore changes in EXTRACT --> restore EXTRACT from TOTAL
      IF vim_special_adjust_mode NE space.
        CLEAR: vim_special_mode, vim_special_adjust_mode,
               <status>-upd_flag, maxlines, <status>-maxlines.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        IF vim_adjust_middle_level_mode NE space.
          function = 'SAVE'.
        ENDIF.
      ENDIF.
      PERFORM fill_extract.
    WHEN OTHERS. RAISE upgrade_view_failed.                 "#EC *
  ENDCASE.
  CLEAR vim_special_mode.
ENDFORM.                               " UPGRADE

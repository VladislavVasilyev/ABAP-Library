*---------------------------------------------------------------------*
*       FORM JUSTIFY_ACTION_MODE                                      *
*---------------------------------------------------------------------*
* ggf. VIEW_ACTION aendern und View entsperren                        *
*---------------------------------------------------------------------*
FORM justify_action_mode.
  TABLES: scdtsync.
  DATA: action_changed(1) TYPE c, assigned(1) TYPE c.
  DATA: i_statetab LIKE adrstatus OCCURS 0 WITH HEADER LINE,
        i_messnbr LIKE sy-msgno, viewtype,                  "#EC *
        msg_v1 LIKE sy-msgv1.
  STATICS: vim_old_cluster TYPE vcl_name."Avoid sync_key_lock messages

  FIELD-SYMBOLS: <f_fld_value> TYPE ANY.  " XB H612358

  IF fcode = vim_read_text.            "SW Textimp ...
    PERFORM vim_read_texttab_all_langus.
    EXIT.
  ENDIF.                               "... SW Textimp

* XB H612358B
* check if the time-field exists: Yes, then reset initial value.
  LOOP AT x_namtab WHERE datatype = 'TIMS'.
    ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <initial>
         TO <f_fld_value>.
    IF <f_fld_value> <> space.
      CLEAR <f_fld_value> WITH space.
    ENDIF.
  ENDLOOP.
* XB H612358B

  IF x_header-selection EQ space.
    DESCRIBE TABLE dba_sellist.
    IF sy-tfill GT 0.
      MOVE 'X' TO x_header-selection.
      MODIFY x_header INDEX 1.
*      IF last_view_info EQ view_name.                       "UF443580b
** <initial> not yet filled in INITIALISIEREN
*        PERFORM vim_set_init_from_sellist USING x_header-maintview
*                                                x_namtab[]
*                                                dba_sellist[]
*                                                vim_hidden
*                                          CHANGING <initial>.
*      ENDIF.                                                "UF443580e
    ELSE.
      DESCRIBE TABLE dpl_sellist.
      IF sy-tfill GT 0.
        MOVE 'X' TO x_header-selection.
        MODIFY x_header INDEX 1.
      ENDIF.
    ENDIF.
  ELSEIF x_header-selection = 'X'.     "XB BCEK064860 begin
*<inital> not filled because the F3. XB int4436226
    DESCRIBE TABLE dba_sellist.
    IF sy-tfill GT 0.
      IF last_view_info EQ view_name.                       "UF443580b
* <initial> not yet filled in INITIALISIEREN
* because with F3 the last_view_info exists.
        PERFORM vim_set_init_from_sellist USING x_header-maintview
                                                x_namtab[]
                                                dba_sellist[]
                                                vim_hidden
                                          CHANGING <initial>.
      ENDIF.                                                "UF443580e
    ENDIF.           "XB BCEK064860 end
  ENDIF.
  IF x_header-adrnbrflag NE space.
* 4.0: check if new version of address maintenance must be used
    CALL FUNCTION 'ADDR_TSADRV_READ'
      EXPORTING
        ddic_tablename  = vim_addr_basetable
        ddic_fieldname  = vim_addr_bastab_field
      IMPORTING
        tsadrv_wa       = vim_tsadrv
      EXCEPTIONS
        entry_not_found = 1.
    IF sy-subrc NE 0.                  "no tsadrv entry found...
      IF x_header-adrnbrflag EQ 'N'.   "new version requires entry
        MESSAGE i287(am) WITH vim_addr_basetable vim_addr_bastab_field.
        CLEAR x_header-adrnbrflag. MODIFY x_header INDEX 1.
      ELSE. "old version runs but is old fashioned....
        IF vim_system_type EQ 'SAP'.   "sap system
          MESSAGE i290(am) WITH vim_addr_basetable  "...send message
                                vim_addr_bastab_field.
        ELSE.
          MESSAGE i291(am) WITH vim_addr_basetable  "...send message
                                vim_addr_bastab_field.
        ENDIF.
      ENDIF.
    ELSE.                              "entry found....
      IF vim_tsadrv-addr_group IS INITIAL. "...but not complete
*       I_TSADRV-ADDR_GROUP = 'CA01'. "default: Customizing Address
        IF x_header-adrnbrflag EQ 'N'. "new version
          i_messnbr = '292'.
        ELSE.                          "old version
          IF vim_system_type EQ 'SAP'. "sap system
            i_messnbr = '288'.
          ELSE.                        "customer system
            i_messnbr = '289'.
          ENDIF.
        ENDIF.
        MESSAGE ID 'AM' TYPE 'I' NUMBER i_messnbr
                        WITH vim_addr_basetable
                             vim_addr_bastab_field
                             vim_tsadrv-tablename
                             vim_tsadrv-fieldname.
        CLEAR x_header-adrnbrflag. MODIFY x_header INDEX 1.
      ELSE.                            "entry in TSADRV is complete
        vim_addr_group = vim_tsadrv-addr_group.
        IF x_header-adrnbrflag EQ 'O'.
          CALL FUNCTION 'ADDR_GET_STATUS_INFO'
            TABLES
              status_table = i_statetab.
          READ TABLE i_statetab WITH KEY
               constant = vim_tsadrv-addr_group.
          IF sy-subrc NE 0. CLEAR i_statetab-value. ENDIF.
          TRANSLATE i_statetab-value USING ' OXN'.
          x_header-adrnbrflag = i_statetab-value.
          MODIFY x_header INDEX 1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  PERFORM vim_process_assigns.
  IF <status>-initializd EQ space.     "not processed yet
* reset dropdown lists
    CALL FUNCTION 'VRM_REFRESH_VALUES'.
    IF x_header-frm_af_ini NE space.   "user exit exists AND
* set environment for user exit.
      ASSIGN dba_sellist-*sys* TO <vim_sellist>.
      vim_enqueue_range = x_header-subsetflag. assigned = 'X'.
* perform user exit -> 3.0B processed in JUSTIFY_ACTION_MODE
      PERFORM (x_header-frm_af_ini) IN PROGRAM (sy-repid).
    ENDIF.
* backup DBA_SELLIST
*    REFRESH vim_dba_sel_kept.                        "UF210200b
*    APPEND LINES OF dba_sellist TO vim_dba_sel_kept.
* remove multiple values for subsets
    DELETE dba_sellist WHERE ddic = 'M'.
    DESCRIBE TABLE dba_sellist.
    IF sy-tfill GT 0.
      READ TABLE dba_sellist INDEX sy-tfill.
      CLEAR dba_sellist-and_or.
      MODIFY dba_sellist INDEX sy-tabix.
    ENDIF.                                                  "UF210200e
  ENDIF.
  IF view_action EQ aendern AND
     function EQ switch_to_update_mode AND
     vim_enq_s_u_rc NE 0.
    MOVE anzeigen TO view_action. action_changed = 'X'.
  ENDIF.
  IF x_header-existency EQ rdonly AND  "read only view
     ( view_action EQ aendern OR       "update or
       view_action EQ transportieren )."transport request
    MOVE anzeigen TO view_action. action_changed = 'X'.
    MESSAGE i044(sv).
  ENDIF.
  IF <status>-corr_nbr EQ vim_locked_in_corr AND "object locked and
     ( view_action EQ aendern OR       "update or
       view_action EQ transportieren )."transport request
    MOVE anzeigen TO view_action. action_changed = 'X'.
  ENDIF.
  IF view_action EQ aendern AND fcode NE read.  "BC-Set Flag not set yet
*---Lock for Synchronizer--------------------------------HCG 08/2003---*
    IF vim_last_objh_view NE view_name.
      IF x_header-bastab EQ space.
        viewtype = 'V'.
      ELSE.
        viewtype = 'S'.
      ENDIF.
      SELECT SINGLE * FROM scdtsync.                        "#EC *
      IF sy-subrc EQ 0.
        CALL FUNCTION 'SCTM_CHECK_VIEW_EDIT'
          EXPORTING
            viewname        = view_name
            viewtype        = viewtype
            bcset           = vim_bcset_id "if NE space -> BC-set act.
          IMPORTING
            edit_flag       = vim_sync_edit_lock
            kespec_flag     = vim_sync_keyspec_check
            sourcesys       = vim_sctm_sourcesys
          EXCEPTIONS
            no_sync_present
            old_sync_system
            rfc_failure.
        IF sy-subrc = 3.   "1 and 2: Message already sent by function
          IF vim_import_profile EQ space.
            MESSAGE w183(sv) WITH sy-msgv1 sy-msgv2.        "#EC *
          ELSE.
            vim_import_no_message = 'X'.
            PERFORM vim_process_message USING 'SV' 'W' 'W' '183'
                                        sy-msgv1 sy-msgv2 space space.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.                            "vim_last_objh_view NE view_name
    IF vim_sync_edit_lock NE space AND      "Table locked completely
       vim_sync_keyspec_check EQ space.
      MOVE anzeigen TO view_action. action_changed = 'X'.
      MOVE vim_sctm_sourcesys TO msg_v1.
      IF vim_import_profile NE space.
        vim_no_dialog = 'X'.
        vim_import_no_message = 'X'.
        PERFORM vim_process_message
                USING
                  'SV' 'E' 'E' '181' msg_v1 space space space.
      ELSE.
        PERFORM vim_process_message
                          USING
                          'SV' 'I' 'I' '181' msg_v1 space space space.
      ENDIF.
    ELSEIF vim_sync_keyspec_check NE space.      "Table locked partly
      IF vim_import_profile EQ space.       "BC-Set act: only message
        MOVE vim_sctm_sourcesys TO msg_v1. "in log when key is locked
        IF vim_calling_cluster NE vim_old_cluster OR
          vim_called_by_cluster EQ space.
          MOVE vim_calling_cluster TO vim_old_cluster.
          PERFORM vim_process_message
                  USING
                    'SV' 'I' 'I' '180' msg_v1 space space space.
        ENDIF.
      ENDIF.
    ENDIF.
*----------------------------------------------------------------------*
    IF vim_last_objh_view NE view_name.
      PERFORM vim_set_ale_edit_lock.
    ENDIF.
    IF vim_ale_edit_lock NE space.
      MOVE anzeigen TO view_action. action_changed = 'X'.
      PERFORM vim_process_message
            USING
              vim_ale_msgid 'I' 'I' vim_ale_msgno
              vim_ale_msgv1 vim_ale_msgv2
              vim_ale_msgv3 vim_ale_msgv4.
    ENDIF.
  ENDIF.
  IF x_header-frm_on_aut NE space AND  "45a: support indiv. auth. chck
     <status>-initializd EQ space.     "not processed yet
    vim_auth_action = view_action.
    vim_auth_event = vim_auth_initial_check.
    ASSIGN dba_sellist[] TO <vim_auth_sellist>.
    PERFORM (x_header-frm_on_aut) IN PROGRAM.
    IF vim_auth_rc NE 0.
      MESSAGE ID vim_auth_msgid TYPE 'I' NUMBER vim_auth_msgno
              WITH vim_auth_msgv1 vim_auth_msgv2
                   vim_auth_msgv3 vim_auth_msgv4.
      CASE vim_auth_rc.
        WHEN 4.                        "show only
          MOVE anzeigen TO view_action. action_changed = 'X'.
        WHEN 8.                        "exit
          RAISE missing_corr_number.
      ENDCASE.
    ENDIF.
  ENDIF.
  IF action_changed NE space.
    IF assigned EQ space.
      ASSIGN dba_sellist-*sys* TO <vim_sellist>.
      vim_enqueue_range = x_header-subsetflag.
    ENDIF.
    PERFORM enqueue USING 'D' x_header-frm_af_enq. "dequeue view
  ENDIF.
  IF x_header-texttbexst <> space.     "SW Texttransl
    PERFORM vim_actualize_d0100.
  ENDIF.
ENDFORM.                    "justify_action_mode

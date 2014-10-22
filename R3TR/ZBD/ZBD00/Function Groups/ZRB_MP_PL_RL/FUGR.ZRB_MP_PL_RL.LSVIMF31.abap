*---------------------------------------------------------------------*
*       FORM UPDATE_TAB                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM update_tab.
  DATA: rc_safe LIKE sy-subrc, tabix LIKE sy-tabix, h_ix TYPE i,
        begdate_safe TYPE d, enddate_safe TYPE d.                    "#EC NEEDED
  CHECK status-action NE anzeigen.
  CHECK status-action NE transportieren.
  CHECK status-delete NE geloescht.
  IF <status>-upd_flag EQ space.
    neuer = 'N'.
    EXIT.
  ENDIF.
  IF status-type EQ einstufig AND status-action EQ hinzufuegen.
    IF ( ( x_header-bastab EQ space OR x_header-texttbexst EQ space )
           AND <table2_x> EQ <initial_x>
         OR x_header-bastab NE space AND x_header-texttbexst NE space
           AND <vim_xextract_enti> EQ <initial_x>
         OR ( vim_special_mode EQ vim_upgrade OR
           vim_single_entry_function NE space ) )
        AND <xact> EQ leer.            "int943578/2000
      neuer = 'J'.
    ELSE.
      neuer = 'N'.
    ENDIF.
  ENDIF.
  IF x_header-frm_h_flds NE space.
    PERFORM (x_header-frm_h_flds) IN PROGRAM.               "Zp 21
  ENDIF.
  IF neuer EQ 'J'.
    IF x_header-guidflag <> space.
      PERFORM vim_make_guid USING space.
    ENDIF.
    IF x_header-frm_on_new NE space.
      PERFORM (x_header-frm_on_new) IN PROGRAM.             "Zp 05
    ENDIF.
    PERFORM check_key.
    MOVE: sy-subrc TO rc_safe, sy-tabix TO tabix.
    IF x_header-adrnbrflag NE space.
      IF vim_special_mode NE vim_upgrade.
        PERFORM address_maintain.
      ELSE.
        PERFORM vim_address_adjust.
      ENDIF.
    ENDIF.
    IF vim_called_by_cluster NE space AND vim_extcopy_mode NE space.
      h_ix = nextline + 1.
      READ TABLE extract INDEX h_ix.
      DELETE extract INDEX h_ix.
      IF x_header-texttbexst <> space. "SW Textcopy
        PERFORM vim_copy_texttab_entry USING <f1_x> <vim_xextract_key>.
      ENDIF.
      PERFORM vim_store_state_info.
      CALL FUNCTION 'VIEWCLUSTER_COPY_DEPENDENT'
           EXPORTING
                view_name   = x_header-viewname
                maintview   = x_header-maintview
                status_mode = status-mode
                workarea    = extract
                new_entry   = <table1>
                no_dialog   = vim_external_mode.
    ENDIF.
    PERFORM nicht_vorhanden USING rc_safe tabix.
  ELSE.
    IF vim_special_mode EQ vim_upgrade.
      PERFORM vim_address_adjust.
    ENDIF.
    IF vim_called_by_cluster NE space.
      CALL FUNCTION 'VIEWCLUSTER_CHECK_MASTER_ENTRY'
           EXPORTING
                check_entry   = <table1>
                view_name     = x_header-viewname
           EXCEPTIONS
                invalid_key   = 1
                invalid_value = 2.
      IF sy-subrc NE 0.
        IF status-mode EQ list_bild.
          SET CURSOR FIELD sy-msgv1 LINE l.
        ELSE.
          SET CURSOR FIELD sy-msgv1.
        ENDIF.
        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
    MOVE exind TO index.
    READ TABLE total WITH KEY <f1_x> BINARY SEARCH.         "#EC *
    IF vim_special_mode NE vim_upgrade.
      PERFORM vorhanden.               "update both tables
    ELSE.
      PERFORM update_entry USING 'X'.
    ENDIF.
  ENDIF.
  MOVE space TO <status>-upd_flag.
ENDFORM.

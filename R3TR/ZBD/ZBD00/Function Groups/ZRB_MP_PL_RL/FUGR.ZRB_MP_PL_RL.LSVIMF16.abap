*&--------------------------------------------------------------------*
*&      Form VIM_IMP_CALL_SCREEN                                      *
*&--------------------------------------------------------------------*
* ...                                                                 *
*&--------------------------------------------------------------------*
FORM vim_imp_call_screen USING vics_screen LIKE d020s-dnum.
  DATA: program LIKE sy-repid, import_action LIKE sy-msgv4,
        key_safe1 LIKE sy-msgv1, key_safe2 LIKE sy-msgv2,
        key_safe3 LIKE sy-msgv3, key_safe TYPE vim_tabkey_c,
        vics_xkeylen TYPE i.           ", vics_int_entsafe(4096) TYPE c.
  LOCAL: imp_results.                  "SW  wg. rek. Aufruf im Cluster

  FIELD-SYMBOLS: <res_tabkey> TYPE x, <errkey> TYPE x.

  ASSIGN: imp_results-tabkey TO <res_tabkey> CASTING,
          vim_profile_errorkey TO <errkey> CASTING.
  CLEAR vim_view_wax.
  IF vim_import_mode_active NE space.
*    VICS_INT_ENTSAFE = <TABLE1>.
    <table1_wax> = <table1_x>.
    PERFORM vim_set_impres_header.
    PERFORM vim_convert_tabkey USING <f1_x> key_safe vics_xkeylen.
*    imp_results-tabkey = <f1>.
    <res_tabkey> = <f1_x>.
    key_safe1 = key_safe.
    IF vics_xkeylen GT 50.
      key_safe2 = key_safe+50.
      IF vics_xkeylen GT 100.
        key_safe3 = key_safe+100.
      ENDIF.
    ENDIF.
    IF vim_called_by_cluster = 'X'.                         "SW
      CONCATENATE '(' view_name ')' INTO key_safe3.         "SW
    ENDIF.                                                  "SW
    IF status-action EQ hinzufuegen.
      import_action = 'INS'.
    ELSEIF function EQ 'DELE'.
      import_action = 'DEL'.
    ELSEIF status-action EQ aendern.
      import_action = 'UPD'.
    ENDIF.
    CLEAR: imp_results-import, vim_last_logged_message.
    IF vim_import_profile = 'X'.
*      vim_profile_errorkey = <f1>.
      <errkey>(x_header-keylen) = <f1_x>.
    ELSE.
      vim_import_no_message = 'X'.
      PERFORM vim_process_message USING 'SV' 'S' 'S' '150' key_safe1
                                      key_safe2 key_safe3 import_action.
    ENDIF.
  ENDIF.
  IF vim_import_mode_active EQ space OR vim_no_dialog EQ space.
    CALL SCREEN vics_screen.
  ELSE.
    program = sy-repid. CLEAR vim_import_no_message.
    CALL FUNCTION 'VIEW_CALL_SCREEN'
         EXPORTING
              screen_number = vics_screen
              program       = program
         EXCEPTIONS
              error_message = 1.
    IF sy-subrc NE 0.
      CLEAR vim_act_dynp_view.
      IF vim_last_logged_message-id NE sy-msgid OR
         vim_last_logged_message-nbr NE sy-msgno.
        vim_import_no_message = 'X'.
        PERFORM vim_process_message USING sy-msgid sy-msgty sy-msgty
                                          sy-msgno sy-msgv1 sy-msgv2
                                          sy-msgv3 sy-msgv4.
      ENDIF.
      IF vim_import_forcemode EQ space.
        ok_code = 'IGN '. neuer = 'N'.
      ELSE.                            "force mode
*        <table1> = vics_int_entsafe.
        <table1_x> = <table1_wax>.
        CASE import_action.
          WHEN 'UPD'.
            <status>-upd_flag = 'X'. neuer = 'N'.
            PERFORM update_tab.
          WHEN 'INS'.
            <status>-upd_flag = 'X'. neuer = 'J'.
            PERFORM update_tab.
          WHEN 'DEL'.
            READ TABLE total WITH KEY <f1_x> BINARY SEARCH  "#EC *
                                             TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.
              PERFORM logical_delete_from_total USING sy-tabix.
            ENDIF.
        ENDCASE.
      ENDIF.
    ENDIF.
    IF vim_import_profile = 'X'.
      CLEAR vim_profile_errorkey.
    ELSE.
      vim_import_no_message = 'X'.
      PERFORM vim_process_message USING 'SV' 'S' 'S' '151' key_safe1
                                      key_safe2 key_safe3 import_action.
    ENDIF.
    CLEAR vim_import_no_message.
  ENDIF.
  IF vim_import_mode_active NE space.
    IF ok_code EQ 'IGN ' OR function EQ 'ABR '. "error
      imp_results-import-errors = 1.
    ENDIF.
    IF ok_code NE 'IGN' AND function NE 'ABR' OR
       vim_import_forcemode NE space.
      CASE import_action.
        WHEN 'UPD'. imp_results-import-updated = 1.
        WHEN 'INS'. imp_results-import-inserted = 1.
        WHEN 'DEL'. imp_results-import-deleted = 1.
      ENDCASE.
    ENDIF.
    APPEND imp_results.
  ENDIF.
ENDFORM.                               "vim_imp_call_screen

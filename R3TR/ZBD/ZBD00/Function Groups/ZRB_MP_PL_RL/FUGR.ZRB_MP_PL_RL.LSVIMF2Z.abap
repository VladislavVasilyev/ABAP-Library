*---------------------------------------------------------------------*
*       FORM UPDATE_ENTRY                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM update_entry USING value(ue_total_only).
  DATA: rec LIKE sy-subrc, tabix LIKE sy-tabix.
  tabix = sy-tabix.
  IF <status>-upd_flag EQ 'X' OR <status>-upd_flag EQ 'E' OR
     <status>-upd_flag EQ 'Y'.
    IF x_header-customauth CO sap_cust_ctrl_classes OR
       vim_ale_keyspec_check NE space OR
       vim_sync_keyspec_check NE space.
      PERFORM check_allowed_keyranges.
    ENDIF.
    MOVE <table1> TO <vim_total_struc>.
*    WRITE <table1> TO total(x_header-tablen).
    IF <xact> EQ original.
      <action>          = aendern.
    ELSE.
      <action>          = <xact>.
    ENDIF.
  ENDIF.
  IF x_header-bastab NE space AND x_header-texttbexst NE space AND
     <status>-upd_flag EQ 'X' OR <status>-upd_flag EQ 'T' OR
     <status>-upd_flag EQ 'Y'.
    IF x_header-customauth CO sap_cust_ctrl_classes OR
       vim_ale_keyspec_check NE space OR
       vim_sync_keyspec_check NE space.
      PERFORM check_allowed_keyranges.
    ENDIF.
    IF <status>-upd_flag NE 'Y'.
      IF <vim_xtotal_text> EQ <text_initial_x>.
        <action_text> = neuer_eintrag.
      ELSE.
        IF <xact_text> EQ original.
          <action_text>          = aendern.
        ELSE.
          <action_text>          = <xact_text>.
        ENDIF.
      ENDIF.
    ENDIF.
    MOVE <table1_xtext> TO <vim_xtotal_text>.
*    MOVE <table1_text> TO <total_text>.
  ENDIF.
  IF replace_mode NE space.
    <mark> = nicht_markiert.
  ELSE.
    <mark> = <xmark>.
  ENDIF.
  MODIFY total  INDEX tabix.                                "#EC *
  IF ue_total_only EQ space.
    IF x_header-delmdtflag NE space.
      PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                                 'X' <vim_begdate>.
      rec = sy-subrc.
    ENDIF.
* do not refresh EXTRACT when there is no function "SRE
* Check for STATUS-ACTION also 26.05.2008          "1073364
    IF ( NOT function IS INITIAL ) OR
       ( <action> NE space ) OR
       ( <status>-upd_flag NE space ).             "1245450
      " Include UPD_FLAG also
      extract = total.
    ENDIF.
* End of change
    IF x_header-delmdtflag EQ space OR rec LT 8.
      IF vim_import_profile = space.
        READ TABLE extract WITH KEY <vim_xextract_key>      "#EC *
                                              TRANSPORTING NO FIELDS.
        IF sy-tabix NE 0.
          MODIFY extract INDEX sy-tabix.                "HCG HW664505
        ELSE.
          MODIFY extract INDEX index.
        ENDIF.
      ELSE.
        MODIFY extract INDEX index.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               "update_entry

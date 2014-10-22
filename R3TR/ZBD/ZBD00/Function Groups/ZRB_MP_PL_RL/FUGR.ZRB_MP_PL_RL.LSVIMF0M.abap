*&--------------------------------------------------------------------*
*&      Form CONSISTENCY_PRT_FRKY_FIELDS                              *
*&--------------------------------------------------------------------*
* make sure, that part. forkey table fields are consistent            *
*&--------------------------------------------------------------------*
FORM consistency_prt_frky_fields
                               USING value(cpff_alert) LIKE tvdir-flag.
  DATA:  prtfky_field_changed(1) TYPE c, cur_mkey_found(1) TYPE c,
         count TYPE i, offs TYPE i,                                        "#EC NEEDED
         formname(19) TYPE c VALUE 'FILL_TEXTTAB_KEY_UC'.
  FIELD-SYMBOLS: <dummy1>.
  LOCAL: total, extract.

  CHECK status-action NE anzeigen.
  CHECK <status>-upd_flag NE space.
  MOVE: <f1_x> TO <vim_xtotal_key>,
        vim_date_mask TO <vim_enddate_mask>,
        <f1_x> TO <vim_h_mkey>,
*        <f1> TO <vim_mainkey_mask>,
        <vim_xtotal_key> TO <f1_x>.
*  vim_mainkey = <f1>.
  IF x_header-selection EQ space.
    LOOP AT total.
      CHECK <vim_xtotal_key> NE <f1_x> AND
            <vim_tot_mkey_beforex> EQ <vim_mkey_beforex> AND
            ( vim_mkey_after_exists EQ space OR
              <vim_tot_mkey_afterx> EQ <vim_mkey_afterx> ).
*      CHECK <vim_total_key> NE <f1> AND
*            <vim_tot_mkey_before> EQ <vim_mkey_before> AND
*            ( vim_mkey_after_exists EQ space OR
*              <vim_tot_mkey_after> EQ <vim_mkey_after> ).
      MOVE 99 TO count.
      EXIT.
    ENDLOOP.
  ELSE.
    MOVE 99 TO count.
  ENDIF.
  IF count EQ 99. "other entries for mainkey (may be) exist
* selections exist or
* prüfen: wurden Texte verändert ?????
* falls aktueller Text leer und hinzufügen --> text aus Extract nehmen
    IF vim_prtfky_assigned CO ' Y'.
* partial foreign key not assigned or VIM_PROCESS_ASSIGNS already
* processed
      CLEAR count.
      LOOP AT x_namtab WHERE prtfrkyfld NE space.
        CHECK x_namtab-readonly EQ space.
        IF vim_prtfky_assigned EQ space.
          IF x_header-bastab EQ space             "view
           OR x_header-texttbexst EQ space        "no texttable
           OR x_namtab-texttabfld EQ space.       "no texttabfield
* not a texttablefield in a table & texttable
            ASSIGN: COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
*            ASSIGN <table1>+x_namtab-position(x_namtab-flength)
                    TO <vim_prtfky_wa>.
          ELSE.
            ASSIGN: COMPONENT x_namtab-viewfield
                     OF STRUCTURE <table1_text>
*            offs = x_namtab-position - x_header-tablen.
*            ASSIGN <table1_text>+offs(x_namtab-flength)
                     TO <vim_prtfky_wa>.
          ENDIF.
        ENDIF.
        IF x_header-bastab EQ space               "view
           OR x_header-texttbexst EQ space        "no texttable
           OR x_namtab-texttabfld EQ space.       "no texttabfield
          ASSIGN: COMPONENT x_namtab-viewfield
                   OF STRUCTURE <vim_total_struc>
                   TO <vim_prtfky_total>,
                  COMPONENT x_namtab-viewfield
                   OF STRUCTURE <vim_extract_struc>
                   TO  <vim_prtfky_extract>.
* not a texttablefield in a table & texttable
        ELSE.
          ASSIGN: COMPONENT x_namtab-viewfield
                    OF STRUCTURE <vim_tot_txt_struc>
                     TO <vim_prtfky_total>,
                    COMPONENT x_namtab-viewfield
                     OF STRUCTURE <vim_ext_txt_struc>
                     TO  <vim_prtfky_extract>.
        ENDIF.
*        ASSIGN: total+x_namtab-position(x_namtab-flength)
*                                 TO <vim_prtfky_total>,
*                extract+x_namtab-position(x_namtab-flength)
*                                 TO <vim_prtfky_extract>.
        CLEAR prtfky_field_changed.
        IF status-action EQ hinzufuegen OR status-action EQ kopieren OR
           vim_special_mode EQ vim_upgrade.
          CLEAR cur_mkey_found.
          LOOP AT total.               "            current mainkey.
            CHECK <vim_tot_mkey_beforex> EQ <vim_mkey_beforex> AND
                  ( vim_mkey_after_exists EQ space OR
                    <vim_tot_mkey_afterx> EQ <vim_mkey_afterx> ).
*            CHECK <vim_tot_mkey_before> EQ <vim_mkey_before> AND
*                  ( vim_mkey_after_exists EQ space OR
*                    <vim_tot_mkey_after> EQ <vim_mkey_after> ).
            cur_mkey_found = 'X'. EXIT.
          ENDLOOP.
          IF cur_mkey_found NE space.
            IF <vim_prtfky_wa> IS INITIAL. "no entry -> use exist. value
              MOVE <vim_prtfky_total> TO <vim_prtfky_wa>.
              TRANSLATE <status>-upd_flag USING 'EY'.
              IF <status>-upd_flag EQ 'Y'.
                PERFORM (formname) IN PROGRAM (sy-repid)
                                   USING <table1> <table1_text>.
              ENDIF.
            ELSEIF <vim_prtfky_wa> NE <vim_prtfky_total>.
              MOVE 'X' TO prtfky_field_changed.
            ENDIF.
          ENDIF.
        ELSEIF <vim_prtfky_wa> NE <vim_prtfky_extract>.
          MOVE 'X' TO prtfky_field_changed.
        ENDIF.
        ADD 1 TO count.
      ENDLOOP.
      IF count EQ 1.
        MOVE 'X' TO vim_prtfky_assigned.
      ENDIF.
    ELSE.     " vim_prtfky_assigned = 'X'
      IF status-action EQ hinzufuegen OR status-action EQ kopieren OR
         vim_special_mode EQ vim_upgrade.
        LOOP AT total.                 "            current mainkey.
          CHECK <vim_tot_mkey_beforex> EQ <vim_mkey_beforex> AND
                ( vim_mkey_after_exists EQ space OR
                  <vim_tot_mkey_afterx> EQ <vim_mkey_afterx> ).
*          CHECK <vim_tot_mkey_before> EQ <vim_mkey_before> AND
*                ( vim_mkey_after_exists EQ space OR
*                  <vim_tot_mkey_after> EQ <vim_mkey_after> ).
          cur_mkey_found = 'X'. EXIT.
        ENDLOOP.
        IF cur_mkey_found NE space.
          IF <vim_prtfky_wa> IS INITIAL. "no entry -> use exist. value
            MOVE <vim_prtfky_total> TO <vim_prtfky_wa>.
            TRANSLATE <status>-upd_flag USING 'EY'.
            IF <status>-upd_flag EQ 'Y'.
              PERFORM (formname) IN PROGRAM (sy-repid)
                                 USING <table1> <table1_text>.
            ENDIF.
          ELSEIF <vim_prtfky_wa> NE <vim_prtfky_total>.
            MOVE 'X' TO prtfky_field_changed.
          ENDIF.
        ENDIF.
      ELSEIF <vim_prtfky_wa> NE <vim_prtfky_extract>.
        MOVE 'X' TO prtfky_field_changed.
      ENDIF.
    ENDIF.
*  if verändert.
    IF prtfky_field_changed NE space.
      IF cpff_alert NE space.
        sy-msgv1 = svim_text_030.
        sy-msgv2 = <vim_mainkey_mask>. TRANSLATE sy-msgv2 USING '+ '.
        IF x_header-clidep NE space.
          SHIFT sy-msgv2 BY client_length PLACES.
        ENDIF.
        count = strlen( sy-msgv2 ).
        ASSIGN sy-msgv2(count) TO <dummy1>.
        REPLACE '&' WITH <dummy1> INTO sy-msgv1.
        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
          EXPORTING
            diagnosetext1  = svim_text_031
            diagnosetext2  = svim_text_032
            diagnosetext3  = svim_text_033
            textline1      = svim_text_034
            textline2      = svim_text_035
            titel          = sy-msgv1
            cancel_display = space
          IMPORTING
            answer         = answer.
      ELSE.
        answer = 'J'.
      ENDIF.
      IF answer EQ 'A'.
        answer = 'N'.
      ENDIF.
      CASE answer.
*       WHEN 'A'. "cancel --> what to do ? same as NO ?
        WHEN 'J'.                      "yes, change all
          IF status-action EQ hinzufuegen OR status-action EQ kopieren.
            PERFORM check_key.
          ELSEIF ( x_header-customauth CO sap_cust_ctrl_classes OR
                   vim_ale_keyspec_check NE space OR
                   vim_sync_keyspec_check NE space ).
            PERFORM check_allowed_keyranges.
          ENDIF.
          LOOP AT total.
            CHECK <vim_xtotal_key> NE <f1_x> AND
                  <vim_tot_mkey_beforex> EQ <vim_mkey_beforex> AND
                  ( vim_mkey_after_exists EQ space OR
                    <vim_tot_mkey_afterx> EQ <vim_mkey_afterx> ).
*            CHECK <vim_total_key> NE <f1> AND
*                  <vim_tot_mkey_before> EQ <vim_mkey_before> AND
*                  ( vim_mkey_after_exists EQ space OR
*                    <vim_tot_mkey_after> EQ <vim_mkey_after> ).
*         move der entsprech. Felder --> gemäß X_NAMTAB, zum PBO füllen
            IF vim_prtfky_assigned CO ' Y'.
              LOOP AT x_namtab WHERE prtfrkyfld NE space.
                IF vim_prtfky_assigned EQ space.
                  IF x_header-bastab EQ space          "view
                   OR x_header-texttbexst EQ space     "no texttable
                   OR x_namtab-texttabfld EQ space.    "no texttabfield
* not a texttablefield in a table & texttable
                    ASSIGN: COMPONENT x_namtab-viewfield
                       OF STRUCTURE <table1>
                       TO <vim_prtfky_wa>,
                     COMPONENT x_namtab-viewfield
                      OF STRUCTURE <vim_total_struc>
                      TO <vim_prtfky_total>.
                  ELSE.
                    ASSIGN: COMPONENT x_namtab-viewfield
                             OF STRUCTURE <table1_text>
                             TO <vim_prtfky_wa>,
                            COMPONENT x_namtab-viewfield
                             OF STRUCTURE <vim_tot_txt_struc>
                             TO <vim_prtfky_total>.
                  ENDIF.
                ENDIF.
*                  IF x_header-bastab EQ space OR
*                     x_header-texttbexst EQ space OR
*                     x_namtab-texttabfld EQ space.
*                    ASSIGN <table1>+x_namtab-position(x_namtab-flength)
*                                              TO <vim_prtfky_wa>.
*                  ELSE.
*                    offs = x_namtab-position - x_header-tablen.
*                    ASSIGN <table1_text>+offs(x_namtab-flength)
*                                              TO <vim_prtfky_wa>.
*                  ENDIF.
*                ENDIF.
*                ASSIGN total+x_namtab-position(x_namtab-flength)
*                                         TO <vim_prtfky_total>.
                MOVE <vim_prtfky_wa> TO <vim_prtfky_total>.
              ENDLOOP.
            ELSE.
              MOVE <vim_prtfky_wa> TO <vim_prtfky_total>.
            ENDIF.
            MODIFY total.
            READ TABLE extract WITH KEY <vim_xtotal_key>.   "#EC *
            IF sy-subrc EQ 0.
              MOVE total TO extract.
              MODIFY extract INDEX sy-tabix.
            ENDIF.
          ENDLOOP.
          vim_prt_fky_flds_updated = 'X'.
        WHEN 'N'.
*       text aus Extract bzw. Total (hinzuf.) nehmen
          IF vim_prtfky_assigned CO ' Y'.
            LOOP AT x_namtab WHERE prtfrkyfld NE space.
              IF vim_prtfky_assigned EQ space.
                IF x_header-bastab EQ space             "view
                 OR x_header-texttbexst EQ space        "no texttable
               OR x_namtab-texttabfld EQ space.       "no texttabfield
* not a texttablefield in a table & texttable
                  ASSIGN: COMPONENT x_namtab-viewfield
                       OF STRUCTURE <table1>
                       TO <vim_prtfky_wa>,
                     COMPONENT x_namtab-viewfield
                      OF STRUCTURE <vim_total_struc>
                      TO <vim_prtfky_total>,
                     COMPONENT x_namtab-viewfield
                      OF STRUCTURE <vim_extract_struc>
                      TO  <vim_prtfky_extract>.
                ELSE.
                  ASSIGN: COMPONENT x_namtab-viewfield
                           OF STRUCTURE <table1_text>
                           TO <vim_prtfky_wa>,
                          COMPONENT x_namtab-viewfield
                           OF STRUCTURE <vim_tot_txt_struc>
                           TO <vim_prtfky_total>,
                          COMPONENT x_namtab-viewfield
                           OF STRUCTURE <vim_ext_txt_struc>
                           TO  <vim_prtfky_extract>.
                ENDIF.
              ENDIF.
*                IF x_header-bastab EQ space OR
*                   x_header-texttbexst EQ space OR
*                   x_namtab-texttabfld EQ space.
*                  ASSIGN <table1>+x_namtab-position(x_namtab-flength)
*                                            TO <vim_prtfky_wa>.
*                ELSE.
*                  offs = x_namtab-position - x_header-tablen.
*                  ASSIGN <table1_text>+offs(x_namtab-flength)
*                                            TO <vim_prtfky_wa>.
*                ENDIF.
*              ENDIF.
*              ASSIGN: total+x_namtab-position(x_namtab-flength)
*                                       TO <vim_prtfky_total>,
*                      extract+x_namtab-position(x_namtab-flength)
*                                       TO <vim_prtfky_extract>.
              IF status-action EQ hinzufuegen OR
                 status-action EQ kopieren OR
                 vim_special_mode EQ vim_upgrade.
                MOVE <vim_prtfky_total> TO <vim_prtfky_wa>.
              ELSE.
                MOVE <vim_prtfky_extract> TO <vim_prtfky_wa>.
              ENDIF.
            ENDLOOP.
          ELSE.
            IF status-action EQ hinzufuegen OR
               status-action EQ kopieren OR
               vim_special_mode EQ vim_upgrade.
              MOVE <vim_prtfky_total> TO <vim_prtfky_wa>.
            ELSE.
              MOVE <vim_prtfky_extract> TO <vim_prtfky_wa>.
            ENDIF.
          ENDIF.
          IF ( x_header-bastab EQ space OR  "view or no texttab and..
               x_header-texttbexst EQ space ) AND
             <table1_x> EQ <vim_xextract>.     "..no change
            CLEAR <status>-upd_flag.
          ELSEIF x_header-bastab NE space AND "bastab with texttab and
                 x_header-texttbexst NE space AND
                 <table1_xtext> EQ <vim_xextract_text>.
* no change of text
            TRANSLATE <status>-upd_flag USING 'XET '.
          ENDIF.
      ENDCASE.
    ENDIF. "vim_prtfky_field_changed ne space
  ENDIF. "COUNT eq 99   other entries for mainkey (may be) exist
ENDFORM.                               "consistency_prt_frky_fields

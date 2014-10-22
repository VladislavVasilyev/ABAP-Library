*---------------------------------------------------------------------*
*       FORM ANZG_TO_AEND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM anzg_to_aend.
  DATA: rc LIKE sy-subrc, dummy TYPE scpr_id, value(200) TYPE c,       "#EC NEEDED
        value_is_external TYPE xfeld, lfieldname TYPE fnam_____4, "#EC NEEDED
        keyvalues TYPE occheckkeyflds, w_keyvalue TYPE occheckkey,
        oc_rangetab TYPE TABLE OF vimsellist, lines TYPE i,
        any_substflds_initial TYPE xfeld, field1 LIKE sy-msgv1, "#EC NEEDED
        field2 LIKE sy-msgv2, field3 LIKE sy-msgv3,
        field4 LIKE sy-msgv4.
  FIELD-SYMBOLS: <w_dba_sel> TYPE vimsellist, <x_namtab> TYPE vimnamtab,
                 <value> TYPE c.                            "#EC *

  IF status-action NE anzeigen AND status-action NE transportieren.
    MESSAGE i001(sv).
  ELSE.
    IF status-action EQ anzeigen.
* check authority
      IF x_header-newgener EQ space. "4.5a: support individual auth.chck
        CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
           EXPORTING
                view_action                = aendern
                view_name                  = view_name
                no_warning_for_clientindep = vim_no_warning_for_cliindep
           CHANGING
                org_crit_inst              = vim_oc_inst
           EXCEPTIONS
                no_authority                   = 8
                no_clientindependent_authority = 9
                no_linedependent_authority     = 11.
        rc = sy-subrc.
        IF sy-subrc = 11.
          MOVE: sy-msgid TO vim_auth_msgid,
                sy-msgno TO vim_auth_msgno,
                sy-msgv1 TO vim_auth_msgv1,
                sy-msgv2 TO vim_auth_msgv2,
                sy-msgv3 TO vim_auth_msgv3,
                sy-msgv4 TO vim_auth_msgv4.
        ENDIF.
      ENDIF.
      IF x_header-frm_on_aut NE space.
        vim_auth_action = aendern.
        vim_auth_event = vim_auth_switch_to_update_mode.
        ASSIGN <vim_ck_sellist> TO <vim_auth_sellist>.
        PERFORM (x_header-frm_on_aut) IN PROGRAM.
        IF vim_auth_rc NE 0. rc = 10. ENDIF.
      ENDIF.
    ENDIF.
    CASE rc.
      WHEN 0.
        IF NOT vim_oc_inst IS INITIAL AND vim_called_by_cluster = space.
* check line-dependent authorisation (viewclusters: will be done in
* viewcluster maintenance.)
* 1st: check non-subset-values
          INSERT LINES OF dba_sellist[] INTO TABLE oc_rangetab.
          LOOP AT x_namtab ASSIGNING <x_namtab> WHERE keyflag <> space
           AND readonly = subset.
            DELETE oc_rangetab WHERE viewfield = <x_namtab>-viewfield.
          ENDLOOP.
          IF sy-subrc = 0.
            DESCRIBE TABLE oc_rangetab LINES lines.
            if lines > 0.
              READ TABLE oc_rangetab ASSIGNING <w_dba_sel> INDEX lines.
              CLEAR <w_dba_sel>-and_or.
            endif.
          ENDIF.
          CALL METHOD vim_oc_inst->check_oc_auth_vim_sellist
            EXPORTING
              sellist    = oc_rangetab
              action     = '02'
*          CHANGING
*            KEY_FIELDS =
            EXCEPTIONS
              no_auth    = 1
              OTHERS     = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            EXIT.
          ENDIF.
          IF x_header-subsetflag <> space.
* 2nd: check subset values
            CALL METHOD vim_oc_inst->build_key_value_tab
              EXPORTING
                entry     = <initial>
              IMPORTING
                keyvalues = keyvalues.
            LOOP AT keyvalues INTO w_keyvalue.
              READ TABLE x_namtab ASSIGNING <x_namtab>
               WITH KEY viewfield = w_keyvalue-keyname.
              CHECK <x_namtab>-readonly <> subset.
              DELETE keyvalues.
            ENDLOOP.
            CALL METHOD vim_oc_inst->check_oc_authority
              EXPORTING
                activity        = '02'
              CHANGING
                key_values      = keyvalues
              EXCEPTIONS
                no_auth         = 1
                key_incomplete  = 2
*              WRONG_PARAMETER = 3
                OTHERS          = 4.
            IF sy-subrc = 1.
              MOVE: sy-msgv1 TO field1, sy-msgv2 TO field2,
                    sy-msgv3 TO field3, sy-msgv4 TO field4.
* no authorisation for current subset values
              MESSAGE i763(sv) WITH field1 field2 field3 field4. "#EC *
*   Sie haben keine Pflegeberechtigung für die angezeigten Datensätze.
              LOOP AT keyvalues INTO w_keyvalue WHERE noauth <> space.    "#EC CI_SORTSEQ
                READ TABLE dba_sellist ASSIGNING <w_dba_sel>
                 WITH KEY viewfield = w_keyvalue-keyname.
                CLEAR: <w_dba_sel>-value, <w_dba_sel>-initial,
                       <w_dba_sel>-from_auth.                "UF210200
              ENDLOOP.
*              CALL METHOD vim_oc_inst->convert_oc_selections
*                        EXPORTING
*                            activity   = '02'
*                        IMPORTING
*                            oc_vimsell = oc_rangetab.
** if possible: fill subset selection in RANGETAB from authority
** (authority object S_TABU_LIN)
*              PERFORM vim_merge_sellists USING    oc_rangetab
*                                                  x_namtab[]
*                                                  'X'
*                                         CHANGING x_header[]
*                                                  dba_sellist
*                                                  rc.
*              PERFORM check_all_substfields TABLES dba_sellist
*                      CHANGING any_substflds_initial.
*              IF any_substflds_initial <> space.
              CALL FUNCTION 'TABLE_RANGE_INPUT'
                   EXPORTING
                        table             = x_header-viewname
                        oc_inst           = vim_oc_inst
                   TABLES
                        sellist           = dba_sellist
                        x_header          = x_header
                        x_namtab          = x_namtab
                   EXCEPTIONS
                        cancelled_by_user = 1
                        no_input          = 2
                        OTHERS            = 3.
              IF sy-subrc <> 0.
                EXIT.
              ENDIF.
*              refresh vim_dba_sel_kept.            "UF210200
*              ENDIF.
            ENDIF.
          ELSE.
* new selection because of different authorisation? --> Message
* >>>check whether there's really a difference between upd and show<<<
            MESSAGE s764(sv).
*   Veränderte Auswahl von Datensätzen.
          ENDIF.                       "subsets exist
        ENDIF.                         "oc exists
        IF status-action EQ transportieren.
          function = switch_transp_to_upd_mode.
          CLEAR <status>-crcntsknwn.
          IF <status>-corr_enqud NE space.
            CALL FUNCTION 'DEQUEUE_E_TRKORR'
                 EXPORTING
                      trkorr = <status>-corr_nbr.
*             X_TRKORR = E02.
            CLEAR <status>-corr_enqud.
          ENDIF.
          IF x_header-cursetting NE space.
            CLEAR: vim_corr_obj_viewname, <status>-tr_alrchkd.
          ENDIF.
        ELSE.
          CLEAR vim_corr_obj_viewname.
          IF <status>-prof_found = vim_profile_found    "UF profileb
             AND vim_pr_records = 0.
* get records the profile contains
            PERFORM get_pr_nbr_records USING vim_profile_values
                                             x_header
                                       CHANGING rc
                                                dummy
                                                vim_pr_records
                                                vim_pr_tab
                                                vim_pr_fields.
* check key-status
            PERFORM get_profile_status CHANGING vim_pr_tab
                                                vim_pr_fields.
            PERFORM bcset_key_check_in_total.
          ENDIF.                       "UF profileb
        ENDIF.
*       SET SCREEN 0.
*       LEAVE SCREEN.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      WHEN 8.                          "no authority for update
        MESSAGE i051(sv).              "only show allowed
      WHEN 9.
        MESSAGE ID 'TB' TYPE 'I' NUMBER 109.      "no cli-indep auth
      WHEN 10 OR 11.
        MESSAGE ID vim_auth_msgid TYPE 'I' NUMBER vim_auth_msgno
                WITH vim_auth_msgv1 vim_auth_msgv2  vim_auth_msgv3
                     vim_auth_msgv4.
    ENDCASE.
  ENDIF.
ENDFORM.

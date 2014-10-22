*---------------------------------------------------------------------*
*       FORM CHECK_DYNAMIC_SELECT_OPTIONS                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_dynamic_select_options.
  DATA: total_ix TYPE i VALUE '2', flag.                                                                                "#EC *
  DATA: cdso_sellist LIKE vimsellist OCCURS 10,
        oc_to_be_checked TYPE xfeld,
        keyvalues TYPE occheckkeyflds,
        activity TYPE xuval.
  FIELD-SYMBOLS: <vim_tot_txt_struc_loc> TYPE ANY.

  IF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab_0.
  ENDIF.
  IF x_header-subsetflag NE space.
    MOVE 'R' TO <status>-sbsid_rcvd.
    LOOP AT dba_sellist WHERE ddic CO vim_subset_marks
                          AND value EQ space
                          AND initial EQ space.
      CLEAR <status>-sbsid_rcvd. EXIT.
    ENDLOOP.
  ENDIF.
  READ TABLE total INDEX 1.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
  IF NOT vim_oc_inst IS INITIAL.
* check authorisation for lines: only for conditions from authorisation
* which could not be included into dba_sellist
    CALL METHOD vim_oc_inst->get_to_be_checked
      IMPORTING
        to_be_checked = oc_to_be_checked.
    IF oc_to_be_checked <> space.
      IF <status>-st_action = anzeigen.
        activity = svorg_read.
      ELSE.
        activity = svorg_maint.
      ENDIF.
      LOOP AT total.
        CALL METHOD vim_oc_inst->build_key_value_tab
          EXPORTING
            entry     = total
          IMPORTING
            keyvalues = keyvalues.
        CALL METHOD vim_oc_inst->check_oc_authority
          EXPORTING
            activity        = activity
          CHANGING
            key_values      = keyvalues
           EXCEPTIONS
             no_auth         = 1
             key_incomplete  = 2
*          WRONG_PARAMETER = 3
             OTHERS          = 4.
        IF sy-subrc = 1.
          DELETE total.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
  LOOP AT dba_sellist.
    IF dba_sellist-ddic CO ddic_marks. "only ddic-limits
      READ TABLE x_namtab INDEX dba_sellist-tabix.
      IF x_namtab-texttabfld NE space OR x_header-bastab EQ space AND
         x_namtab-bastabname NE x_header-roottab.
        CLEAR dba_sellist-ddic.
      ENDIF.
    ENDIF.
    APPEND dba_sellist TO cdso_sellist.
  ENDLOOP.
  READ TABLE total INDEX 1.                                 "IG 951411
  IF x_header-bastab <> space AND x_header-texttbexst <> space.
    ASSIGN <vim_tot_txt_struc> TO <vim_tot_txt_struc_loc>.
  ELSE.
    ASSIGN <vim_total_struc> TO <vim_tot_txt_struc_loc>.
  ENDIF.
  CALL FUNCTION 'TABLE_RANGE_CHECK'
    EXPORTING
      tabname                   = x_header-maintview
      entry                     = total
      entry_text                = <vim_tot_txt_struc_loc>
      ddic                      = 'N'
      key                       = 'N'
      ignore_blank_subsetfields = 'J'
    TABLES
      x_namtab                  = x_namtab
      x_header                  = x_header
      sellist                   = cdso_sellist
    EXCEPTIONS
      entry_not_fits            = 1
      no_value_for_subset_ident = 2.
  CASE sy-subrc.
    WHEN 0.
      IF x_header-delmdtflag NE space.
        PERFORM build_mainkey_tab_1. flag = 'X'.
      ENDIF.
    WHEN 1.
      DELETE total INDEX 1.
      SUBTRACT 1 FROM total_ix.
    WHEN 2.
      CLEAR <status>-sbsid_rcvd.
  ENDCASE.
  LOOP AT total FROM total_ix.
    CALL FUNCTION 'TABLE_RANGE_CHECK'
      EXPORTING
        tabname                   = x_header-maintview
        entry                     = total
        entry_text                = <vim_tot_txt_struc_loc>
        ddic                      = 'N'
        key                       = 'N'
        ignore_blank_subsetfields = 'J'
      TABLES
        x_namtab                  = x_namtab
        x_header                  = x_header
        sellist                   = cdso_sellist
      EXCEPTIONS
        entry_not_fits            = 1
        no_value_for_subset_ident = 2.
    CASE sy-subrc.
      WHEN 0.
        IF x_header-delmdtflag NE space.
          PERFORM build_mainkey_tab_1. flag = 'X'.
        ENDIF.
      WHEN 1.
        DELETE total.
      WHEN 2.
        CLEAR <status>-sbsid_rcvd.
    ENDCASE.
  ENDLOOP.
  IF flag NE space.
    PERFORM build_mainkey_tab_2.
  ENDIF.
ENDFORM.                    "check_dynamic_select_options

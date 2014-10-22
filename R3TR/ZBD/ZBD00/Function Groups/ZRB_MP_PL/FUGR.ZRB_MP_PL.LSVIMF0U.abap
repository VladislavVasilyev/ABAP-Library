*&--------------------------------------------------------------------*
*&      Form X_CALL_VIEWMAINTENANCE                                   *
*&--------------------------------------------------------------------*
* external call of view maintenance                                   *
*&--------------------------------------------------------------------*
* --> XCV_USE_LCL_TBL:  'X' Datencontainer XCV_TOTAL und XCV_EXTRACT
*                       sind nicht struktueriert und nicht vom Typ X
*                       => Daten müssen in lokale Container umgesetzt
*                       werden.
* --> XCV_IMP_SPECMODE: 'P' Profilimport/
*                       'T' Testmodus Import/'F' Forcemodus Import /
*                       'B' T + F Import
*&--------------------------------------------------------------------*
FORM x_call_viewmaintenance USING
                                value(xcv_use_lcl_tbl) LIKE tvdir-flag
                                value(xcv_import) LIKE tvdir-flag
                                xcv_corrnbr LIKE e070-trkorr
                                value(xcv_fcode) TYPE vimty_tcode
                                value(xcv_action) LIKE tvdir-flag
                                value(xcv_name) TYPE vimty_tablename
                                value(xcv_tot_name) TYPE c
                                value(xcv_ext_name) TYPE c
                                value(xcv_upgr_dest) LIKE rfcdes-rfcdest
                                value(xcv_upgr_clnt) LIKE sy-mandt
                                xcv_upd_requ LIKE tvdir-flag
                                xcv_e071k TYPE table
                                xcv_dba_sel TYPE table
                                xcv_dpl_sel TYPE table
                                xcv_excufc TYPE table
                                xcv_extract TYPE table
                                xcv_total TYPE table
                                xcv_header TYPE table
                                xcv_namtab TYPE table
                                xcv_last_command TYPE vimty_tcode
                                xcv_last_act_entry LIKE sy-tabix
                                xcv_results LIKE vimmodres
                                xcv_imp_results TYPE slctr_tables_keys
                                value(xcv_imp_specmode) LIKE tvdir-flag
                                value(xcv_cmp_slcnds) LIKE tvdir-flag.

  DATA: xcv_return TYPE i, xcv_i_fcode TYPE vimty_tcode,                   "#EC NEEDED
        line_name(30) TYPE c, length TYPE i, tabtype TYPE ob_typ,
        header_wa_loc TYPE vimdesc,
        BEGIN OF tabline,
          line(4096) TYPE c,
        END OF tabline.
  FIELD-SYMBOLS: <total> TYPE table, <extract> TYPE table,
                 <tabline> TYPE ANY, <tabline_x> TYPE x,
                 <tabline2> TYPE ANY, <tabline2_x> TYPE x,
                 <header> TYPE vimdesc.
  LOCAL: vim_import_mode_active, vim_no_dialog, vim_import_testmode,
         vim_import_forcemode.          "SW  wg. Rekurs. im Cluster

  vim_no_dialog = xcv_import. TRANSLATE vim_no_dialog USING 'H DX'.
  IF xcv_imp_specmode = 'P'.           "Profilimp
    vim_import_profile = 'X'.
  ENDIF.
  vim_import_testmode = xcv_imp_specmode.
  TRANSLATE vim_import_testmode USING 'TXBXF P '.
  vim_import_forcemode = xcv_imp_specmode.
  TRANSLATE vim_import_forcemode USING 'T BXFXP '.
  IF xcv_use_lcl_tbl NE space.
    ASSIGN: (xcv_tot_name) TO <total>, (xcv_ext_name) TO <extract>.
    IF xcv_use_lcl_tbl NE 'L'.         "use not _only_ local tables
      READ TABLE xcv_header ASSIGNING <header> CASTING INDEX 1.
      IF <header>-bastab NE space AND <header>-texttbexst NE space.
        length = <header>-after_tabc + <header>-aft_txttbc
                 + 3 * cl_abap_char_utilities=>charsize.
      ELSE.
        length = <header>-after_tabc
                 + 2 * cl_abap_char_utilities=>charsize.
      ENDIF.
      SEARCH xcv_tot_name FOR '[' IN CHARACTER MODE.
      MOVE xcv_tot_name(sy-fdpos) TO line_name.
      ASSIGN: (line_name) TO <tabline2>,
              <tabline2> TO <tabline2_x> CASTING.
      REFRESH: <total>, <extract>.
      LOOP AT xcv_total ASSIGNING <tabline>.
        ASSIGN <tabline> TO <tabline_x> CASTING.
        MOVE <tabline_x> TO <tabline2_x>(length).
        APPEND <tabline2> TO <total>.
      ENDLOOP.
      LOOP AT xcv_extract ASSIGNING <tabline>.
        ASSIGN <tabline> TO <tabline_x> CASTING.
        MOVE <tabline_x> TO <tabline2_x>(length).
        APPEND <tabline2> TO <extract>.
      ENDLOOP.
*      <total> = xcv_total. <extract> = xcv_extract.
    ENDIF.
  ELSE.
    ASSIGN: xcv_total TO <total>, xcv_extract TO <extract>.
  ENDIF.
  vim_import_mode_active = xcv_import. xcv_i_fcode = xcv_fcode.
  IF xcv_import NE space AND xcv_fcode NE 'SAVE'.
  ELSEIF xcv_import NE space AND xcv_fcode EQ 'SAVE'.       "SW
    imp_results[] = xcv_imp_results[].                      "SW
  ELSEIF xcv_fcode EQ 'INS' OR xcv_fcode EQ 'DEL' OR
         xcv_fcode EQ 'UPD' OR xcv_fcode EQ 'SHOW'.
    vim_single_entry_function = xcv_fcode. xcv_i_fcode = 'EDIT'.
  ENDIF.
  IF xcv_import EQ 'D' AND xcv_fcode EQ 'SAVE'.
    vim_import_no_message = 'X'.
  ENDIF.
  CALL FUNCTION 'VIEW_MAINTENANCE_LOW_LEVEL'
    EXPORTING
      corr_number                 = xcv_corrnbr
      fcode                       = xcv_i_fcode
      view_action                 = xcv_action
      view_name                   = xcv_name
      rfc_destination_for_upgrade = xcv_upgr_dest
      client_for_upgrade          = xcv_upgr_clnt
      complex_selconds_used       = xcv_cmp_slcnds
    IMPORTING
      last_act_entry              = xcv_last_act_entry
      ucomm                       = xcv_last_command
      update_required             = xcv_upd_requ
      corr_number                 = xcv_corrnbr
    TABLES
      corr_keytab                 = xcv_e071k
      dba_sellist                 = xcv_dba_sel
      dpl_sellist                 = xcv_dpl_sel
      excl_cua_funct              = xcv_excufc
      extract                     = <extract>
      total                       = <total>
      x_header                    = xcv_header
      x_namtab                    = xcv_namtab
    EXCEPTIONS
      function_not_found          = 1
      missing_corr_number         = 2
      no_value_for_subset_ident   = 3
      saving_correction_failed    = 4.
*  IF xcv_import NE space AND
*     ( sy-subrc NE 0 OR
*       xcv_fcode EQ save AND <status>-upd_flag NE space ).
* "HCG BC-Set: sy-subrc NE 0 -> always error message in log
  IF ( xcv_import NE space OR vim_import_profile NE space ) AND
     ( sy-subrc NE 0 OR
       xcv_fcode EQ save AND <status>-upd_flag NE space ).
    IF sy-msgid NE space.
      vim_import_no_message = 'X'.
      IF vim_import_profile = 'X'.
        READ TABLE xcv_header INTO header_wa_loc INDEX 1.
        IF header_wa_loc-bastab EQ space.
          tabtype = 'V'.
        ELSE.
          tabtype = 'S'.
        ENDIF.
        PERFORM vim_bc_process_message USING sy-msgid 'I' 'E' sy-msgno
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 tabtype.
      ELSE.
        PERFORM vim_process_message USING sy-msgid 'I' 'E' sy-msgno
                       sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      CLEAR vim_import_no_message.
    ENDIF.
*   IF XCV_IMPORT NE SPACE.
    LOOP AT imp_results.
      IF imp_results-import-inserted NE 0.
        imp_results-import-errors = imp_results-import-inserted.
        CLEAR imp_results-import-inserted.
      ELSEIF imp_results-import-updated NE 0.
        imp_results-import-errors = imp_results-import-updated.
        CLEAR imp_results-import-updated.
      ELSEIF imp_results-import-deleted NE 0.
        imp_results-import-errors = imp_results-import-deleted.
        CLEAR imp_results-import-deleted.
      ENDIF.
      MODIFY imp_results.
    ENDLOOP.
  ELSEIF xcv_import EQ space AND xcv_fcode EQ 'READ' AND
         sy-subrc NE 0.                "probably called by VIEW_GET_DATA
    IF sy-subrc EQ 2. "probably individual authority check failed
      MESSAGE i053(sv) RAISING no_authority.
    ELSE.                              "other error
      MESSAGE i037(sv) WITH view_name RAISING no_viewmaint_tool.
    ENDIF.
  ENDIF.
  IF xcv_fcode EQ 'EXED' OR xcv_fcode EQ 'DEL'.
    xcv_results = vim_results_of_ext_mod.
  ELSEIF xcv_fcode EQ read.
    DESCRIBE TABLE <total> LINES xcv_results-nbr_of_upd.
  ELSEIF xcv_fcode EQ save AND xcv_import EQ 'D'.
    CLEAR vim_import_no_message.
  ENDIF.
  IF xcv_use_lcl_tbl NE space AND xcv_use_lcl_tbl NE 'L'.
    REFRESH: xcv_total, xcv_extract.
    ASSIGN: tabline TO <tabline2_x> CASTING.
    LOOP AT <total> ASSIGNING <tabline>.
      ASSIGN <tabline> TO <tabline_x> CASTING.
      MOVE <tabline_x> TO <tabline2_x>(length).
      APPEND tabline TO xcv_total.
    ENDLOOP.
    LOOP AT <extract> ASSIGNING <tabline>.
      ASSIGN <tabline> TO <tabline_x> CASTING.
      MOVE <tabline_x> TO <tabline2_x>(length).
      APPEND tabline TO xcv_extract.
    ENDLOOP.
*    MOVE: <total> TO xcv_total, <extract> TO xcv_extract.
  ENDIF.
  CLEAR vim_single_entry_function.                          "SW
  IF xcv_import NE space.
    xcv_imp_results = imp_results[].
    REFRESH imp_results.                                    "SW
  ENDIF.
ENDFORM.                               "x_call_viewmaintenance

*---------------------------------------------------------------------*
*       FORM SELECT                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PARAM                                                         *
*  <--  SY-SUBRC                                                      *
*---------------------------------------------------------------------*
FORM select USING param.
  FIELD-SYMBOLS: <vim_tot_txt_struc_loc> TYPE ANY.

  sy-subrc = 8.
  IF param EQ space AND status-action NE transportieren.
    "normal selection (not deleted entries)
    PERFORM normal_select.
  ELSE.
    CASE param.
      WHEN geloescht.
        CHECK <action>         EQ geloescht
        OR    <action>         EQ neuer_geloescht
        OR    <action>         EQ update_geloescht.
        CLEAR sy-subrc.
        IF x_header-selection NE space.
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
              ignore_blank_subsetfields = 'N'
            TABLES
              x_namtab                  = x_namtab
              x_header                  = x_header
              sellist                   = dpl_sellist
            EXCEPTIONS
              entry_not_fits            = 1
              no_value_for_subset_ident = 2.
          IF sy-subrc EQ 2.
            RAISE no_value_for_subset_ident.
          ENDIF.
        ENDIF.
      WHEN markiert.
        IF status-delete EQ geloescht.
          CHECK <action> EQ geloescht OR <action> EQ neuer_geloescht OR
                <action> EQ update_geloescht.
        ENDIF.
        CHECK <mark>   EQ param.
        CLEAR sy-subrc.
        IF x_header-selection NE space.
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
              ignore_blank_subsetfields = 'N'
            TABLES
              x_namtab                  = x_namtab
              x_header                  = x_header
              sellist                   = dpl_sellist
            EXCEPTIONS
              entry_not_fits            = 1
              no_value_for_subset_ident = 2.
          IF sy-subrc EQ 2.
            RAISE no_value_for_subset_ident.
          ENDIF.
        ENDIF.
      WHEN bcset_only.               "HCG Display only data from BC-Set
        IF vim_actlinks NE x_header-viewname.
          PERFORM vim_bc_logs_get USING view_name x_header x_namtab[]
                          CHANGING vim_bc_entry_list.
          vim_actlinks = x_header-viewname."For which actlinks are valid
        ENDIF.
        READ TABLE vim_bc_entry_list INTO vim_bc_entry_list_wa
                 WITH TABLE KEY viewname = x_header-maintview "HCG 9/04
                                  keys = <vim_xtotal_key>.
        IF sy-subrc NE 0. sy-subrc = 8. ENDIF.
        CHECK sy-subrc EQ 0.
        IF x_header-selection NE space.
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
              ignore_blank_subsetfields = 'N'
            TABLES
              x_namtab                  = x_namtab
              x_header                  = x_header
              sellist                   = dpl_sellist
            EXCEPTIONS
              entry_not_fits            = 1
              no_value_for_subset_ident = 2.
          IF sy-subrc EQ 2.
            RAISE no_value_for_subset_ident.
          ENDIF.
        ENDIF.
      WHEN by_field_contents.
        PERFORM normal_select.
        CHECK sy-subrc EQ 0.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
* table with texttable
          CALL FUNCTION 'QUERY_CHECK'
            EXPORTING
              record            = <vim_total_struc>
              textrecord        = <vim_tot_txt_struc>
            EXCEPTIONS                                      "#EC *
              no_hits_in_record = 4
              parameter_error   = 8.
        ELSE.
* view or single table
          CALL FUNCTION 'QUERY_CHECK'
               EXPORTING
                    record            = <vim_total_struc>
*                  record            = total
               EXCEPTIONS                                  "#EC *
                    no_hits_in_record = 4
                    parameter_error   = 8.
        ENDIF.
      WHEN OTHERS.                     "neuer_eintrag or aendern
       IF x_header-bastab NE space AND x_header-texttbexst NE space AND
                  param EQ aendern.
          CHECK <action> EQ param OR <action_text> EQ param OR
                <action> NE neuer_eintrag AND
                <action_text> EQ neuer_eintrag.
        ELSE.
          CHECK <action> EQ param.
        ENDIF.
        CLEAR sy-subrc.
        IF x_header-selection NE space.
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
              ignore_blank_subsetfields = 'N'
            TABLES
              x_namtab                  = x_namtab
              x_header                  = x_header
              sellist                   = dpl_sellist
            EXCEPTIONS
              entry_not_fits            = 1
              no_value_for_subset_ident = 2.
          IF sy-subrc EQ 2.
            RAISE no_value_for_subset_ident.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF."param eq space and status-action ne transportieren
ENDFORM.                    "select

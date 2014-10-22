*---------------------------------------------------------------------*
*       FORM NORMAL_SELECT                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
* <--- sy-subrc                                                       *
*---------------------------------------------------------------------*
FORM normal_select.
  FIELD-SYMBOLS: <ns_tab> TYPE table, <vim_tot_txt_struc_loc> TYPE ANY.
  sy-subrc = 8.
  CHECK <action> NE neuer_geloescht
    AND <action> NE update_geloescht
    AND <action> NE geloescht.
  CLEAR sy-subrc.
  IF x_header-selection NE space.
    IF vim_special_adjust_mode NE space.
      ASSIGN dba_sellist[] TO <ns_tab>.
    ELSE.
      ASSIGN dpl_sellist[] TO <ns_tab>.
    ENDIF.
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
        sellist                   = <ns_tab>
      EXCEPTIONS
        entry_not_fits            = 1
        no_value_for_subset_ident = 2.
    IF sy-subrc EQ 2.
      RAISE no_value_for_subset_ident.
    ENDIF.
  ENDIF.
ENDFORM.                    "NORMAL_SELECT

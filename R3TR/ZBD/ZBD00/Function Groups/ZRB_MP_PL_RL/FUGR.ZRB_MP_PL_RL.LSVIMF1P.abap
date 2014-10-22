*---------------------------------------------------------------------*
*       FORM PREPARE_READ_REQUEST                                     *
*---------------------------------------------------------------------*
*       prepare global data for read request                          *
*---------------------------------------------------------------------*
FORM prepare_read_request.

  DATA: action TYPE activ_auth, oc_to_be_checked TYPE xfeld,
        sellines TYPE i, viewtype.                          "#EC *

  PERFORM init_state_vector.
  PERFORM vim_reset_texttab USING view_name.           "SW Texttransl
  IF <status>-st_action NE anzeigen AND                 "HCG HW680584
    vim_import_profile = space.     "No actlinks needed in activation
* If table completely locked by cust distribution -> no bc-locks needed
    IF x_header-bastab EQ space.
      viewtype = 'V'.
    ELSE.
      viewtype = 'S'.
    ENDIF.
    CALL FUNCTION 'SCTM_CHECK_VIEW_EDIT'
             EXPORTING
               viewname        = view_name
               viewtype        = viewtype
               bcset           = vim_bcset_id "if NE space -> BC-set act.
             IMPORTING
               edit_flag       = vim_sync_edit_lock
               kespec_flag     = vim_sync_keyspec_check
               sourcesys       = vim_sctm_sourcesys
             EXCEPTIONS                                     "#EC *
               no_sync_present
               old_sync_system
               rfc_failure.
    IF vim_sync_edit_lock NE space AND      "Table locked completely
       vim_sync_keyspec_check EQ space.
    ELSE.
      PERFORM vim_bc_logs_get USING view_name x_header x_namtab[]
                            CHANGING vim_bc_entry_list.
      vim_actlinks = x_header-viewname. "For which actlinks are valid
    ENDIF.
  ENDIF.
  IF vim_adjust_middle_level_mode EQ subset. "ignore subsets
    vim_adj_header = x_header[].
    CLEAR x_header-subsetflag. MODIFY x_header INDEX 1.
    vim_adj_namtab = x_namtab[].
    LOOP AT x_namtab WHERE readonly EQ subset AND keyflag NE space.
      CLEAR x_namtab-readonly. MODIFY x_namtab.
    ENDLOOP.
    vim_adj_dbasellist = dba_sellist[].
    LOOP AT dba_sellist WHERE ddic CO vim_subset_marks.
      IF dba_sellist-value IS INITIAL AND dba_sellist-initial EQ space.
        DELETE dba_sellist. "unvollständige Subsetbedingungen löschen
      ELSE.
        TRANSLATE dba_sellist-ddic USING 'S BX'. "'S A BXMX'.
        MODIFY dba_sellist.
      ENDIF.
    ENDLOOP.
    DESCRIBE TABLE dba_sellist.
    IF sy-tfill GT 0.
      READ TABLE dba_sellist INDEX sy-tfill.
      CLEAR dba_sellist-and_or.
      MODIFY dba_sellist INDEX sy-tabix.
    ENDIF.
  ENDIF.
* remove old selections from authorisation
*  if not vim_dba_sel_kept is initial and vim_called_by_cluster = space.
*    refresh dba_sellist[].                                 "UF210200b
*    append lines of vim_dba_sel_kept to dba_sellist.
*  endif.
*  DELETE dba_sellist WHERE ddic = 'M'.
  IF vim_called_by_cluster = space.
    DELETE dba_sellist WHERE from_auth <> space
     AND ddic <> 'S' and ddic <> 'B'.                       "UF210200e
    DESCRIBE TABLE dba_sellist LINES sellines.
    IF sellines GT 0.
      READ TABLE dba_sellist INDEX sellines.
      CLEAR dba_sellist-and_or.
      MODIFY dba_sellist INDEX sy-tabix.
    ENDIF.
  ENDIF.                                                     "UF210200
  IF NOT vim_oc_inst IS INITIAL.
* insert selection from authorisation into sellist
    IF <status>-st_action = anzeigen.
      action = svorg_read.
    ELSE.
      action = svorg_maint.
    ENDIF.
    CALL METHOD vim_oc_inst->combine_vimsel_with_auth
      EXPORTING
        action  = action
      CHANGING
        sellist = dba_sellist[].
    CALL METHOD vim_oc_inst->get_to_be_checked
      IMPORTING
        to_be_checked = oc_to_be_checked.
    IF oc_to_be_checked <> space or x_header-bastab <> space.
* check TOTAL vs. authorisation after reading
      PERFORM vim_maint_selflag USING    'S'
                                CHANGING x_header-selection.
    ENDIF.
  ENDIF.
ENDFORM.                    "prepare_read_request

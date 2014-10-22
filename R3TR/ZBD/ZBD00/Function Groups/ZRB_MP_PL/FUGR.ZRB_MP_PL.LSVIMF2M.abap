*---------------------------------------------------------------------*
*       FORM KOPIERE_EINTRAG                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ORIGIN                                                        *
*---------------------------------------------------------------------*
FORM kopiere_eintrag USING origin.
  DATA: ke_index LIKE sy-tabix, ke_rc LIKE sy-subrc, ke_hf TYPE i.
  field-symbols: <x_origin> type x.

  IF status-mode EQ list_bild AND function NE 'KOPF' AND "scrolling &
     <status>-upd_flag EQ space.       "no changes
    EXIT.
  ENDIF.
  assign origin to <x_origin> casting.
  IF vim_special_mode NE vim_delimit.
    IF x_header-guidflag <> space.
      PERFORM vim_make_guid using space.
    ENDIF.
    IF x_header-frm_on_new NE space.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
        EXIT.
      ENDIF.
      PERFORM (x_header-frm_on_new) IN PROGRAM (sy-repid).
    ENDIF.
    IF <f1_x> EQ <x_origin>.
      PERFORM set_pf_status USING 'ERROR'.
      MESSAGE e015(sv).
      EXIT.
    ELSE.
      neuer = 'J'.
      PERFORM check_key.
      neuer = 'N'.
      CHECK sy-subrc NE 0.
      MOVE: sy-subrc TO ke_rc,
            sy-tabix TO ke_index.
    ENDIF.
  ELSE.
    READ TABLE total WITH KEY <f1_x> BINARY SEARCH.         "#EC *
    MOVE: sy-subrc TO ke_rc,
          sy-tabix TO ke_index.
  ENDIF.
* gültiger Eintrag.
  IF vim_special_mode NE vim_delimit.  "copy mode
    IF x_header-bastab NE space AND x_header-texttbexst NE space AND
       <status>-upd_flag EQ 'E'.
      PERFORM (vim_frm_text_upd_flag) IN PROGRAM.
    ENDIF.
    IF x_header-adrnbrflag NE space.
      PERFORM address_maintain.
    ENDIF.
    IF x_header-texttbexst <> space.   "SW Textcopy
      PERFORM vim_copy_texttab_entry USING <f1_x> <vim_xextract_key>.
    ENDIF.
    IF vim_called_by_cluster NE space.
      PERFORM vim_store_state_info.
      CALL FUNCTION 'VIEWCLUSTER_COPY_DEPENDENT'
           EXPORTING
                view_name   = x_header-viewname
                maintview   = x_header-maintview
                status_mode = status-mode
                workarea    = extract
                new_entry   = <table1>
                no_dialog   = vim_external_mode.
      PERFORM vim_restore_state_info.
    ENDIF.
  ENDIF.
  IF vim_special_mode NE vim_delimit OR ke_rc NE 0.
    <action> = neuer_eintrag.
    <mark> = nicht_markiert.
  ELSE.                                "delimit mode and existing entry
    IF <action> EQ original. <action> = aendern. ENDIF.
  ENDIF.
  ADD 1 TO counter.
*  MOVE <table1> TO total(x_header-tablen).
  MOVE <table1> TO <vim_total_struc>.
  IF x_header-bastab NE space AND x_header-texttbexst NE space AND
     <status>-upd_flag EQ 'X' OR <status>-upd_flag EQ 'T'.
    MOVE <table1_xtext> TO <vim_xtotal_text>.
    IF vim_special_mode NE vim_delimit OR ke_rc NE 0.
      MOVE neuer_eintrag TO <action_text>.
    ELSE.
      IF <action_text> EQ original. <action_text> = aendern. ENDIF.
    ENDIF.
  ENDIF.
  vim_copied_indices-ex_ix = nextline.
  vim_copied_indices-level = vim_copy_call_level.
  CASE ke_rc.
    WHEN 0.
      MODIFY total INDEX ke_index.
      READ TABLE vim_copied_indices WITH KEY ix = ke_index
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        vim_copied_indices-ix = ke_index.
        INSERT vim_copied_indices INDEX sy-tabix.
      ENDIF.
    WHEN 4.
      INSERT total INDEX ke_index.
      READ TABLE vim_copied_indices WITH KEY ix = ke_index
                                    BINARY SEARCH
                                    TRANSPORTING NO FIELDS.
      vim_copied_indices-ix = ke_index.
      INSERT vim_copied_indices INDEX sy-tabix.
      ke_hf = sy-tabix + 1.
      LOOP AT vim_copied_indices FROM ke_hf.
        ADD 1 TO vim_copied_indices-ix.
        MODIFY vim_copied_indices.
      ENDLOOP.
    WHEN 8.
      APPEND total.
      vim_copied_indices-ix = ke_index.
      APPEND vim_copied_indices.
  ENDCASE.
  neuer = 'N'.
  <status>-upd_flag = space.
  READ TABLE total WITH KEY <x_origin> BINARY SEARCH.       "#EC *
  IF sy-subrc = 0 AND <mark> EQ markiert.
    <mark> = nicht_markiert.
    SUBTRACT 1 FROM mark_total.
    MODIFY total INDEX sy-tabix.
  ENDIF.
  IF status-mode EQ detail_bild.
    vim_next_screen = 0. vim_leave_screen = 'X'.
  ENDIF.
ENDFORM.

*&--------------------------------------------------------------------*
*&      Form ZURUECKHOLEN                                             *
*&--------------------------------------------------------------------*
* Behandeln der Funktion 'UNDO'                                       *
*---------------------------------------------------------------------*
FORM zurueckholen.

  DATA: number_of_ign_entr TYPE i, key_safe TYPE tabl1024,
        z_ign_entr_ex(1) TYPE c, z_specmode_safe(1) TYPE c.

  IF status-action NE aendern OR status-delete NE geloescht.
    MESSAGE i001(sv).
    EXIT.
  ENDIF.
  CLEAR counter. z_specmode_safe = vim_special_mode.
  vim_special_mode = vim_undelete.
  IF status-mode EQ detail_bild.
    MOVE <xmark> TO deta_mark_safe.
    IF x_header-delmdtflag NE space.
      PERFORM check_if_entry_is_to_display USING 'L' <vim_xextract_key>
                                                 space <vim_begdate>.
      number_of_ign_entr = sy-subrc.
      key_safe = <vim_xextract_key>.
    ENDIF.
*   IF <STATUS>-DISPL_MODE EQ EXPANDED.
    IF x_header-delmdtflag EQ space OR number_of_ign_entr LT 8.
      READ TABLE extract INDEX nextline.
    ELSE.
      READ TABLE total WITH KEY key_safe BINARY SEARCH.     "#EC *
      extract = total.
    ENDIF.
  ENDIF.
  IF x_header-frm_bf_udl NE space.
    PERFORM (x_header-frm_bf_udl) IN PROGRAM (sy-repid).
  ENDIF.
  IF vim_called_by_cluster NE space.
    PERFORM vim_store_state_info.
    CALL FUNCTION 'VIEWCLUSTER_UNDO_DEPENDENT'
         EXPORTING
              view_name         = x_header-viewname
              status_mode       = status-mode
              workarea          = extract
              no_dialog         = vim_external_mode
         IMPORTING
              ign_entries_exist = z_ign_entr_ex.
    IF z_ign_entr_ex NE space.
      ignored_entries_exist = z_ign_entr_ex.
    ENDIF.
  ENDIF.
  IF status-mode EQ list_bild.
    PERFORM liste_zurueckholen.
  ELSE.
    IF <xmark> NE uebergehen.
      PERFORM detail_zurueckholen.
    ENDIF.
  ENDIF.
  IF replace_mode NE space AND counter EQ 0.
    function = ok_code = 'IGN '.
  ENDIF.
  IF x_header-frm_af_udl NE space.
    PERFORM (x_header-frm_af_udl) IN PROGRAM (sy-repid).
  ELSE.
    IF ignored_entries_exist NE space.
      PERFORM mark_ignored_entries CHANGING number_of_ign_entr.
      IF replace_mode EQ space.
        IF number_of_ign_entr EQ 1.
          MESSAGE s113(sv). "Eintrag konnte nicht zurückgeholt werden
        ELSEIF number_of_ign_entr GT 1.
          MESSAGE s114(sv) WITH number_of_ign_entr.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
* CLEAR VIM_SPECIAL_MODE.
  vim_special_mode = z_specmode_safe.
ENDFORM.                               " ZURUECKHOLEN

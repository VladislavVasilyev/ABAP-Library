*---------------------------------------------------------------------*
*       FORM LISTE_BACK                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM liste_back.
  IF status-action EQ hinzufuegen.
    status-action = <status>-st_action = aendern.
    title-action  = aendern.
    CLEAR <status>-selected.
    neuer = 'N'.
  ENDIF.
  IF status-delete = geloescht.
    status-delete = <status>-st_delete = nicht_geloescht.
    title-action  = aendern.
    PERFORM markiere_alle USING nicht_markiert.
  ENDIF.
  IF x_header-delmdtflag NE space.
    LOOP AT vim_collapsed_mainkeys.
      IF vim_collapsed_mainkeys-mkey_bf EQ space.
        vim_collapsed_mainkeys-mkey_bf = vim_collapsed_mainkeys-log_key.
        CLEAR vim_collapsed_mainkeys-log_key.
      ENDIF.
      <f1_x> = <vim_h_coll_mkey>.
*      <f1> = vim_collapsed_mainkeys-mainkey.
      <vim_enddate_mask> = space.
      <vim_h_coll_mkey> = <f1_x>.
*      vim_collapsed_mainkeys-mainkey = <f1>.
      MODIFY vim_collapsed_mainkeys.
    ENDLOOP.
    IF vim_delim_expa_excluded NE space.
      DELETE excl_cua_funct WHERE function EQ 'EXPA'.
      CLEAR vim_delim_expa_excluded.
    ENDIF.
    IF status-action = aendern AND title-action = hinzufuegen.
      title-action  = aendern.
    ENDIF.
  ENDIF.
  PERFORM fill_extract.
  nextline = 1.
  mark_extract = mark_total.
  SET SCREEN liste.
  LEAVE SCREEN.
ENDFORM.

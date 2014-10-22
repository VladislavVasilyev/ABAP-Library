*---------------------------------------------------------------------*
*       FORM SELEKTIERE                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PARAM                                                         *
*---------------------------------------------------------------------*
FORM selektiere USING param.
  DATA: rec LIKE sy-subrc VALUE 9, s_screenmode(1) TYPE c VALUE 'S'. "#EC NEEDED
  IF status-action EQ hinzufuegen.
    status-action = aendern.
    title-action = aendern.
  ENDIF.
  IF status-mode EQ detail_bild.
    PERFORM update_tab.
  ENDIF.
  REFRESH extract. CLEAR vim_mainkey. l = 1.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  LOOP AT total.
    PERFORM select USING param.
    CHECK sy-subrc EQ 0.
    IF x_header-delmdtflag NE space.
      PERFORM check_and_modify_mainkey_tab USING rec.
      IF rec NE 0.
        vim_coll_mainkeys_beg_ix = vim_last_coll_mainkeys_ix.
      ENDIF.
      CHECK rec LT 8.
      IF rec EQ 4. rec = 9. ENDIF.
    ENDIF.
    extract = total.
    APPEND extract.
  ENDLOOP.
  vim_coll_mainkeys_beg_ix = 1.
  IF rec NE 9 AND rec NE 0.
    PERFORM mod_extract_and_mainkey_tab USING 'A' 0.
  ENDIF.
  IF param EQ geloescht.
    status-delete = geloescht.
    title-action  = geloescht.
  ENDIF.
  <status>-selected = param.
  DESCRIBE TABLE extract LINES maxlines.
  status-data   = auswahldaten.
  title-data    = auswahldaten.
  nextline = 1.
  IF maxlines EQ 0.
    status-delete = nicht_geloescht.
    title-action  = nicht_geloescht.
    PERFORM fill_extract.
    PERFORM set_pf_status USING status.
    MESSAGE i004(sv).
    SET SCREEN liste.
    LEAVE SCREEN.
  ENDIF.
  IF maxlines EQ 1.
    MESSAGE s005(sv).
    IF vim_single_entry_function NE space.
      IF status-type EQ zweistufig.
        <status>-firstline = <status>-cur_line = nextline.
        PERFORM process_detail_screen USING 'C'.
      ELSE.
        CALL SCREEN liste.
      ENDIF.
    ELSE.
      IF status-type EQ zweistufig.
        <status>-firstline = <status>-cur_line = nextline.
        PERFORM process_detail_screen USING 'S'.
      ENDIF.
    ENDIF.
  ELSE.
    IF status-mode EQ detail_bild.
      vim_next_screen = liste. vim_leave_screen = 'X'.
    ENDIF.
    MESSAGE s006(sv) WITH maxlines.
  ENDIF.
ENDFORM.

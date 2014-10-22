*---------------------------------------------------------------------*
*       FORM SUCHEN                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM suchen.
  DESCRIBE TABLE exclude_tab.
  IF sy-tfill GT 0.                    "entries in old exclude_tab
    PERFORM consider_old_exclude_tab TABLES excl_que_tab.
  ENDIF.
  CALL FUNCTION 'QUERY_GET_OPERATION'
       EXPORTING
            table             = x_header-maintview
       TABLES
            exclude_fields    = excl_que_tab
       EXCEPTIONS
            table_not_found   = 0004
            no_valid_fields   = 0008
            cancelled_by_user = 0012.
  CASE sy-subrc.
    WHEN 0.
    WHEN 8.
      MESSAGE s039(sv) WITH view_name.
      EXIT.
    WHEN OTHERS.
      EXIT.
  ENDCASE.
  status-data   = auswahldaten.
  title-data    = auswahldaten.
  IF title-action EQ geloescht.
    status-delete = nicht_geloescht.
    title-action = aendern.
  ENDIF.
  REFRESH extract.
  LOOP AT total.
    PERFORM select USING by_field_contents.
    CHECK sy-subrc EQ 0.
    extract = total.
    APPEND extract.
  ENDLOOP.
  <status>-selected = by_field_contents.
  DESCRIBE TABLE extract LINES maxlines.
  nextline = 1.
  IF maxlines EQ 0.
    PERFORM fill_extract.
    MESSAGE s004(sv).
    EXIT.
  ENDIF.
  IF maxlines EQ 1.
    MESSAGE s005(sv).
    IF status-type EQ zweistufig.
      PERFORM read_table USING maxlines.
      PERFORM process_detail_screen USING 'S'.
    ENDIF.
  ELSE.
    IF status-mode EQ detail_bild.
      vim_next_screen = liste. vim_leave_screen = 'X'.
    ENDIF.
  ENDIF.
  MESSAGE s006(sv) WITH maxlines.
  mark_extract = 0.
  LOOP AT extract.
    IF <xmark> EQ markiert.
      mark_extract = mark_extract + 1.
    ENDIF.
  ENDLOOP.
  IF x_header-delmdtflag <> space.        "SW CSS-Problem 83157/1999
    LOOP AT extract.
      LOOP AT vim_collapsed_mainkeys.
        CHECK <vim_collapsed_mkey_bfx> = <vim_ext_mkey_beforex>
         AND <vim_collapsed_keyx> <> <vim_xextract_key>.
*      LOOP AT vim_collapsed_mainkeys WHERE
*                mkey_bf = <vim_ext_mkey_before>.
*        IF vim_collapsed_mainkeys-mainkey <> <vim_extract_key>.
        DELETE vim_collapsed_mainkeys.
*        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.

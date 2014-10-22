*---------------------------------------------------------------------*
*       FORM POPUP_POSITIONIEREN                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM popup_positionieren.
  DATA: pp_program LIKE sy-repid, hf1 TYPE i, hf2 TYPE i,
        dummy type xfeld.                          "#EC NEEDED

  IF status-action NE anzeigen AND status-action NE transportieren
  AND status-mode NE list_bild.
    PERFORM update_tab.
  ENDIF.
  pp_program = sy-repid.
  <table1> = <initial>.
  CALL FUNCTION 'TABLE_GET_KEY_TO_SET_CUR_ROW'
       EXPORTING
            table             = x_header-maintview          "Subviews
            f4_programname    = pp_program
            f4_formname       = 'F4_POSITIONIEREN'
       IMPORTING
            table_key         = dummy
       TABLES
            sellist           = <vim_ck_sellist>
            exclude_fields    = excl_pos_tab
       CHANGING
            table_key_new     = <f1_x>
       EXCEPTIONS
            cancelled_by_user = 01
            table_not_found   = 02.
  CHECK sy-subrc EQ 0000.
  IF x_header-frm_h_flds NE space.
    PERFORM (x_header-frm_h_flds) IN PROGRAM. "#EC *
  ENDIF.
  IF x_header-frm_rp_pos NE space.
    PERFORM (x_header-frm_rp_pos) IN PROGRAM. "#EC *
  ELSEIF status-action EQ hinzufuegen AND status-mode EQ list_bild.
    nextline = 0.
    LOOP AT extract. "#EC *
      IF <xact> EQ leer. EXIT. ENDIF.
*      CHECK <vim_extract_key> LE <f1>.
      CHECK <vim_xextract_key> LE <f1_x>.
      hf1 = sy-tabix.
      CHECK <vim_xextract_key> EQ <f1_x>.
      nextline = sy-tabix. EXIT.
    ENDLOOP.
    IF nextline EQ 0.
      IF hf1 EQ maxlines.
        nextline = hf1.
      ELSE.
        nextline = hf1 + 1.
      ENDIF.
    ENDIF.
  ELSE.
*    READ TABLE extract WITH KEY <f1> BINARY SEARCH
*                                     TRANSPORTING NO FIELDS.
    READ TABLE extract WITH KEY <f1_x> BINARY SEARCH                "#EC *
                                       TRANSPORTING NO FIELDS.
    nextline = sy-tabix.
    CLEAR old_nl.                                           "GKPR - 0001009660
    IF sy-subrc = 8 AND nextline GT 1.
      nextline = nextline - 1.                              "last entry
    ENDIF.
  ENDIF.
  IF status-mode EQ detail_bild.
    READ TABLE extract INDEX nextline.   "#EC *                   "ufdetailb
    IF <xmark> <> markiert.
      CLEAR <status>-mark_only.
    ENDIF.                                                  "ufdetaile
    hf2 = firstline + looplines - 1.
    IF looplines EQ 0.
      l = 1. MOVE: l TO <status>-cur_line,
                   nextline TO <status>-firstline.
      hf1 = 0.
    ELSEIF nextline GE firstline AND nextline LE hf2.
* nothing to scroll.
    ELSEIF nextline LT firstline.                  "xb2002 int405493/99
* if the nextline less than firstline, move the nextline to firstline.
      firstline = nextline.
    ELSE.                                           "xb2002 int405493/99
* if the nextline larger than firstline, move the nextline to firstline.
       firstline = nextline.
    ENDIF.
    l = nextline - firstline + 1.
    MOVE: firstline TO <status>-firstline,
          l         TO <status>-cur_line.
  ELSE.
    MOVE 1 TO l.
  ENDIF.
ENDFORM.

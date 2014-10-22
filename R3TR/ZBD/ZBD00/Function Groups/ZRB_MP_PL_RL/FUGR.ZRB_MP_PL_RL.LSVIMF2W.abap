*---------------------------------------------------------------------*
*       FORM HINZUFUEGEN                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM hinzufuegen.
  DATA: h_screenmode(1) TYPE c VALUE 'S'.
  CASE status-action.
    WHEN hinzufuegen.
      nextline = maxlines.
    WHEN aendern.
      REFRESH extract.
      maxlines = 0.
      nextline = <status>-cur_line = 1.
      IF status-type EQ zweistufig.
        firstline = <status>-firstline = nextline.
      ENDIF.
      IF vim_single_entry_function EQ 'INS'.
        h_screenmode = 'C'.
      ENDIF.
    WHEN OTHERS.
      MESSAGE i001(sv).
      EXIT.
  ENDCASE.
  MOVE <initial> TO <table1>.
  IF x_header-clidep NE space.
    MOVE sy-mandt TO <client>.
  ENDIF.
  MOVE <table1> TO <vim_extract_struc>.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    MOVE: <text_initial> TO <table1_text>,
          <table1_xtext> TO <vim_xextract_text>.
*          <table1_text> TO <extract_text>.
  ENDIF.
  status-action = hinzufuegen.
  <status>-selected = neuer_eintrag.
  status-data   = auswahldaten.
  title-action  = hinzufuegen.
  title-data    = auswahldaten.
  neuer  = 'J'.
  IF status-type EQ zweistufig.
    PERFORM process_detail_screen USING h_screenmode.
  ELSE.
    IF vim_single_entry_function EQ 'INS'.
      nbr_of_added_dummy_entries = 1.
    ELSEIF looplines EQ 0.
      MOVE 50 TO nbr_of_added_dummy_entries.
    ELSE.
      MOVE looplines TO nbr_of_added_dummy_entries.
    ENDIF.
    MOVE leer TO <xact>. clear <xmark>.
    DO nbr_of_added_dummy_entries TIMES.
      APPEND extract.
    ENDDO.
    IF h_screenmode EQ 'S'.
      SET SCREEN liste.
      LEAVE SCREEN.
    ELSE.
      CALL SCREEN liste.
    ENDIF.
  ENDIF.
ENDFORM.

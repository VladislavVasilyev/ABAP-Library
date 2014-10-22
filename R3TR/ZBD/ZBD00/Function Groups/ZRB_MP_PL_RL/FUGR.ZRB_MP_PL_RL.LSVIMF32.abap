*---------------------------------------------------------------------*
*       FORM READ_TABLE                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IND                                                           *
*---------------------------------------------------------------------*
FORM read_table USING ind.
  IF replace_mode NE space OR vim_special_mode EQ vim_delete.
    EXIT.
  ENDIF.
  READ TABLE extract INDEX ind.
  MOVE sy-tabix TO exind.
  IF sy-subrc NE 0.
    MOVE <initial> TO <table1>.
    MOVE <table1> TO <vim_extract_struc>.
    IF x_header-bastab NE space AND x_header-texttbexst NE space.
      MOVE: <text_initial_x> TO <vim_xextract_text>,
            <text_initial_x> to <table1_xtext>.
*            <table1_text> TO <extract_text>.
    ENDIF.
    IF status-mode EQ detail_bild AND status-action EQ hinzufuegen AND
       neuer EQ 'N'.                   "e.g. 'PREV' without input
      neuer = 'J'.
    ENDIF.
  ELSE.
    PERFORM move_extract_to_view_wa.
  ENDIF.
ENDFORM.

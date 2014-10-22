*&--------------------------------------------------------------------*
*&      Form  MOVE_EXTRACT_TO_VIEW_WA                                 *
*&--------------------------------------------------------------------*
* move EXTRACT entry to view-/table-/texttable-workarea               *
*&--------------------------------------------------------------------*
FORM move_extract_to_view_wa.

  MOVE <vim_extract_struc> TO <table1>.
*  MOVE EXTRACT TO <TABLE1>.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
*    MOVE <extract_text> TO <table1_text>.
    MOVE <vim_xextract_text> TO <table1_xtext>.
  ENDIF.
ENDFORM.                               "move_extract_to_view_wa.

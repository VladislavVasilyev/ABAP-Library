*---------------------------------------------------------------------*
*       FORM MODIFY_TABLES                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(TAB_INDEX)                                              *
*---------------------------------------------------------------------*
FORM modify_tables USING value(tab_index).
  CLEAR <status>-upd_flag.
  IF <xmark> EQ markiert.
    SUBTRACT: 1 FROM <status>-mk_xt,
              1 FROM <status>-mk_to.
  ENDIF.
  READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
  MOVE <table1> TO <vim_extract_struc>.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    MOVE: <table1_xtext> TO <vim_xextract_text>,
          original TO <xact_text>.
  ENDIF.
  <xmark> = nicht_markiert.
  <xact> = original.
  IF tab_index NE 0.
    MODIFY extract INDEX tab_index.
  ENDIF.
  total = extract.
  MODIFY total INDEX sy-tabix.
  IF x_header-frm_on_org NE space.
    PERFORM (x_header-frm_on_org) IN PROGRAM (sy-repid).
  ENDIF.
ENDFORM.

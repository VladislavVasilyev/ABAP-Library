*---------------------------------------------------------------------*
*       FORM INIT_SUBSET_FCTFIELDS                                    *
*---------------------------------------------------------------------*
* init subset fields which are not keyfields                          *
*---------------------------------------------------------------------*
* FORMNAME --> name of FORM to get view work area filled with current *
*              subset field values                                    *
* PROGNAME --> program of FORM 'FORMNAME'                             *
*---------------------------------------------------------------------*
FORM init_subset_fctfields USING value(formname) value(progname).

  DATA: alr_read TYPE c.

  LOOP AT x_namtab WHERE readonly EQ subset AND keyflag EQ space.
    ASSIGN component x_namtab-viewfield of structure <initial>
           TO <subsetfield>.
    ASSIGN component x_namtab-viewfield of structure <table1>
           TO <value>.
    IF alr_read EQ space.
      MOVE <initial> TO <table1>.
      IF x_header-clidep NE space.
        MOVE sy-mandt TO <client>.
      ENDIF.
      IF x_header-frm_rp_cpl NE space.   "event AD
        PERFORM (x_header-frm_rp_cpl) IN PROGRAM (sy-repid).
      ELSEIF formname NE compl_formname OR progname NE sy-repid.
        PERFORM (formname) IN PROGRAM (progname) USING <table1>.
      ELSEIF maxlines EQ 0.
        PERFORM (compl_formname) IN PROGRAM (sy-repid) USING <table1>
                                 IF FOUND.
      ELSE.
        READ TABLE extract INDEX 1.
        MOVE <vim_extract_struc> TO <table1>.
      ENDIF.
      IF vim_called_by_cluster NE space.
        CALL FUNCTION 'VIEWCLUSTER_COMPL_SUBSET_VALUE'
             EXPORTING
                  view_name = x_header-viewname
             CHANGING
                  workarea  = <table1>.
      ENDIF.
      MOVE 'X' TO  alr_read.
    ENDIF.
    MOVE <value> TO <subsetfield>.
  ENDLOOP.
  IF sy-subrc NE 0 AND maxlines EQ 0.
    MOVE <initial> TO <table1>.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM FILL_SUBSETFIELDS                                        *
*---------------------------------------------------------------------*
*  fill subset fields in *view-wa                                     *
*---------------------------------------------------------------------*
FORM FILL_SUBSETFIELDS.
  DATA: progname LIKE sy-repid.
  IF <STATUS>-SBSID_RCVD CO ' R'.
    progname = sy-repid.
    PERFORM INIT_SUBSET_FCTFIELDS USING COMPL_FORMNAME progname.
    TRANSLATE <STATUS>-SBSID_RCVD USING ' XRS'.
  ELSE.
    IF MAXLINES EQ 0 OR VIM_CALLED_BY_CLUSTER NE SPACE.
      MOVE <INITIAL> TO <TABLE1>.
    ENDIF.
  ENDIF.
ENDFORM.

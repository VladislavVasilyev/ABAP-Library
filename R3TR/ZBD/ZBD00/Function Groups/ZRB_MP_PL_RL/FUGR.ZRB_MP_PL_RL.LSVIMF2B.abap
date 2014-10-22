*---------------------------------------------------------------------*
*       FORM COMPLETE_EXPROFIELDS                                     *
*---------------------------------------------------------------------*
*  fill read only fields of referenced tables (exp ro tables)         *
*---------------------------------------------------------------------*
FORM COMPLETE_EXPROFIELDS.
  IF X_HEADER-FRM_RP_CPL NE SPACE.
    PERFORM (X_HEADER-FRM_RP_CPL) IN PROGRAM.
  ELSE.
    PERFORM (COMPL_FORMNAME) IN PROGRAM (SY-REPID) USING <TABLE1>
                                 IF FOUND.
  ENDIF.
  IF VIM_CALLED_BY_CLUSTER NE SPACE.
    CALL FUNCTION 'VIEWCLUSTER_COMPL_SUBSET_VALUE'
         EXPORTING
              VIEW_NAME = X_HEADER-VIEWNAME
         CHANGING
              WORKAREA  = <TABLE1>.
  ENDIF.
ENDFORM.                               "complete_exprofields

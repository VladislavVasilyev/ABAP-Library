*&--------------------------------------------------------------------*
*&      Form VIM_RESTORE_LOCAL_MEMORY                                 *
*&--------------------------------------------------------------------*
* restore local memory of function pool (for external call)           *
*&--------------------------------------------------------------------*
FORM VIM_RESTORE_LOCAL_MEMORY.
  DATA: H_NAME(31) TYPE C VALUE '*', H_STATE(30) VALUE 'STATUS_'.

  VIEW_NAME = X_HEADER-VIEWNAME.
  IF X_HEADER-BASTAB EQ SPACE.
    H_NAME+1 = X_HEADER-MAINTVIEW. H_STATE+7 = X_HEADER-MAINTVIEW.
    ASSIGN: (X_HEADER-MAINTVIEW) TO <TABLE1>, (H_NAME) TO <INITIAL>,
            (H_STATE) TO <STATUS>.
  ENDIF.
  VIM_RESTORE_MODE = 'X'.
  PERFORM INITIALISIEREN.
  VIEW_ACTION = <STATUS>-ST_ACTION. TRANSLATE VIEW_ACTION USING 'CUAU'.
  PERFORM JUSTIFY_ACTION_MODE.
  MOVE: VIEW_ACTION TO MAINT_MODE,
        <STATUS>-CORR_NBR TO CORR_NBR,
        <STATUS>-FCODE TO FUNCTION.
  PERFORM CALL_DYNPRO.
ENDFORM.                               "vim_restore_local_memory

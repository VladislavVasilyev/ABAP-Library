*&--------------------------------------------------------------------*
*&      Form  PROCESS_AFTER_ENTRY_RESET                               *
*&--------------------------------------------------------------------*
*                                                                     *
*---------------------------------------------------------------------*
FORM PROCESS_AFTER_ENTRY_RESET.
  IF TEMPORAL_DELIMITATION_HAPPENED NE SPACE.
    PERFORM AFTER_TEMPORAL_DELIMITATION.
    CLEAR TEMPORAL_DELIMITATION_HAPPENED.
  ENDIF.
  PERFORM CHECK_UPD.
  IF X_HEADER-FRM_AF_ORG NE SPACE.
    PERFORM (X_HEADER-FRM_AF_ORG) IN PROGRAM (SY-REPID).
  ENDIF.
ENDFORM.                               "process_after_entry_reset

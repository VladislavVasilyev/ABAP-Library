*----------------------------------------------------------------------*
*   INCLUDE LSVIMF50                                                   *
*----------------------------------------------------------------------*

FORM VIM_VCLDOCKING_CONTROL.
DATA: DISABLE_NAVI(1) TYPE C.

  IF VIM_EXTERNAL_MODE = 'X' OR VIM_SPECIAL_MODE = VIM_DIRECT_UPGRADE
     OR STATUS-ACTION = 'C'.
    DISABLE_NAVI = 'X'.
  ENDIF.
  CALL FUNCTION 'VIEWCLUSTER_NAVI_CONTROL'
       EXPORTING
            OWNER_REPID        = X_HEADER-FPOOLNAME
            OWNER_DYNNR        = SY-DYNNR
            DISABLE_NAVIGATION = DISABLE_NAVI
       EXCEPTIONS
            OTHERS             = 1.
  IF SY-SUBRC = 0.
    MOVE 'ATAB' TO EXCL_CUA_FUNCT-FUNCTION. COLLECT EXCL_CUA_FUNCT.
  ENDIF.
ENDFORM.                                  " VIM_VCLDOCKING_CONTROL

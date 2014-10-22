*&--------------------------------------------------------------------*
*&      Form DELIMITATION                                             *
*&--------------------------------------------------------------------*
* process temporal delimitation of marked EXTRACT entries             *
*&--------------------------------------------------------------------*
FORM DELIMITATION.
  LOCAL: <TABLE1>, <TABLE1_TEXT>.
  DATA: D_RC(1) TYPE C.
* request date to delimit
  CALL FUNCTION 'POPUP_GET_VALUES'
       EXPORTING
            POPUP_TITLE     = SVIM_TEXT_036
            START_COLUMN    = '10'
            START_ROW       = '10'
       IMPORTING
            RETURNCODE      = D_RC
       TABLES
            FIELDS          = VIM_SVAL_TAB
       EXCEPTIONS
            ERROR_IN_FIELDS = 01.
  IF SY-SUBRC NE 0. RAISE GET_VALUES_ERROR. ENDIF.          "#EC *
  CHECK D_RC NE 'A'.
  READ TABLE VIM_SVAL_TAB INDEX 1.
  VIM_SPECIAL_MODE = VIM_DELIMIT.
  CLEAR: COUNTER, VIM_OLD_VIEWKEY.
  TRANSLATE VIM_NO_MAINKEY_EXISTS USING VIM_NO_MKEY_NOT_PROCSD_PATT.

* Event 28 AFter Entering Delimitation Date                   "CG 7/2001
  if x_header-frm_af_edd NE SPACE.
    PERFORM (x_header-frm_af_edd) IN PROGRAM (x_header-fpoolname).
  endif.

  PERFORM KOPIERE.
  IF TEMPORAL_DELIMITATION_HAPPENED NE SPACE.
    REFRESH VIM_DELIM_ENTRIES. CLEAR TEMPORAL_DELIMITATION_HAPPENED.
  ENDIF.
  CLEAR: VIM_SPECIAL_MODE.
ENDFORM.                               "delimitation

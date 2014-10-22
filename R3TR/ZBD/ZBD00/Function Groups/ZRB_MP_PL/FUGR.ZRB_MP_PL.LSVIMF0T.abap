*&--------------------------------------------------------------------*
*&      Form  X_CALL_SCREEN                                           *
*&--------------------------------------------------------------------*
* external call of specified view maintenance screen                  *
*&--------------------------------------------------------------------*
FORM X_CALL_SCREEN USING VALUE(XCS_SCREEN) LIKE D020S-DNUM.
  CALL SCREEN XCS_SCREEN.
ENDFORM.                               "x_call_screen

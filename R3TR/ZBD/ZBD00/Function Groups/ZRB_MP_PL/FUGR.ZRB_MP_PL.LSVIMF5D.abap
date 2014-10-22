*----------------------------------------------------------------------*
*   INCLUDE LSVIMF5D                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VIM_MAINT_SELFLAG
*&---------------------------------------------------------------------*
*       Sets or resets X_HEADER-SELECTION and keeps initial value
*       Purpose: additional check vs. sellist in form
*       CHECK_DYNAMIC_SELECT_OPTIONS
*----------------------------------------------------------------------*
*      -->mode   S = set flag to 'X', I = initialize,
*                R = get and reset to initial value
*      <--p_selflag value of X_HEADER-SELECTION
*----------------------------------------------------------------------*
FORM vim_maint_selflag USING    value(p_mode) TYPE sychar01
                   CHANGING p_selflag     TYPE xfeld.

  STATICS: init_val TYPE xfeld.

  CASE p_mode.
    WHEN 'I'.
      init_val = p_selflag.
    WHEN 'S'.
      x_header-selection = 'X'.                            "#EC *
    WHEN 'R'.
      p_selflag = x_header-selection.
      x_header-selection = init_val.
  ENDCASE.
ENDFORM.                               " VIM_MAINT_SELFLAG

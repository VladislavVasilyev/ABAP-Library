*&--------------------------------------------------------------------*
*&      Form  BUILD_MAINKEY_TAB_2                                     *
*&--------------------------------------------------------------------*
* build mainkey tab for display modification - part two               *
*&--------------------------------------------------------------------*
FORM BUILD_MAINKEY_TAB_2.
  APPEND VIM_COLLAPSED_MAINKEYS.
  MOVE: X_HEADER-VIEWNAME TO VIM_MEMORY_ID_1-VIEWNAME,
        SY-UNAME          TO VIM_MEMORY_ID_1-USER.
  EXPORT VIM_COLLAPSED_MAINKEYS TO MEMORY ID VIM_MEMORY_ID_1.
ENDFORM.                               "build_mainkey_tab_2

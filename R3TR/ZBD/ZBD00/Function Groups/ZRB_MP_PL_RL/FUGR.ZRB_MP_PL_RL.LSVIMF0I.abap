*&--------------------------------------------------------------------*
*&      Form  BUILD_MAINKEY_TAB                                       *
*&--------------------------------------------------------------------*
* build mainkey tab for display modification - all parts              *
*&--------------------------------------------------------------------*
FORM BUILD_MAINKEY_TAB.
  PERFORM BUILD_MAINKEY_TAB_0.
  LOOP AT TOTAL.
    PERFORM BUILD_MAINKEY_TAB_1.
  ENDLOOP.
  PERFORM BUILD_MAINKEY_TAB_2.
ENDFORM.                               "build_mainkey_tab

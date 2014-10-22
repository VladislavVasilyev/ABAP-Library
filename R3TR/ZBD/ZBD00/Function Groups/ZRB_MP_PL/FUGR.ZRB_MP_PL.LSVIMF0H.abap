*&--------------------------------------------------------------------*
*&      Form  BUILD_MAINKEY_TAB_0                                     *
*&--------------------------------------------------------------------*
* build mainkey tab for display modification - part one               *
*&--------------------------------------------------------------------*
FORM BUILD_MAINKEY_TAB_0.
  CLEAR: VIM_MAINKEY, VIM_MERGED_ENTRIES, VIM_COLLAPSED_MAINKEYS,
         <TABLE1>, VIM_MERGE_BEGIN, VIM_MERGE_END.
  TRANSLATE VIM_NO_MAINKEY_EXISTS USING VIM_NO_MKEY_NOT_PROCSD_PATT.
  REFRESH: VIM_COLLAPSED_MAINKEYS,
           VIM_MERGED_ENTRIES.
  VIM_COLL_MKEYS_FIRST = 'X'.
ENDFORM.                               "build_mainkey_tab_0

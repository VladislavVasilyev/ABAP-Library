*&--------------------------------------------------------------------*
*&      Form  DELETE_FROM_MAINKEY_TAB                                 *
*&--------------------------------------------------------------------*
* delete entry from mainkey_tab.                                      *
*&--------------------------------------------------------------------*
FORM delete_from_mainkey_tab.
  LOOP AT vim_collapsed_mainkeys.
    CHECK <vim_h_coll_mkey>(x_header-keylen) = <f1_x>.
*  LOOP AT VIM_COLLAPSED_MAINKEYS WHERE MAINKEY EQ <F1>.
    DELETE vim_collapsed_mainkeys.
  ENDLOOP.
ENDFORM.                               "delete_from_mainkey_tab

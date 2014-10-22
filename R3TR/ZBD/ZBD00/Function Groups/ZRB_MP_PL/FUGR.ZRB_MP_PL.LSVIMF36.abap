*---------------------------------------------------------------------*
*       FORM MOD_EXTRACT_AND_MAINKEY_TAB                              *
*---------------------------------------------------------------------*
*       Modify EXTRACT and mainkey table                              *
*---------------------------------------------------------------------*
FORM mod_extract_and_mainkey_tab USING value(meamt_mode) TYPE c
                                       value(meamt_index) TYPE i.
  CASE meamt_mode.
    WHEN 'A'.
      APPEND extract.
    WHEN 'I'.
      IF meamt_index EQ 0.
        INSERT extract.                                 "#EC *
      ELSE.
        INSERT extract INDEX meamt_index.
      ENDIF.
    WHEN 'M'.
      IF meamt_index EQ 0.
        MODIFY extract.                                 "#EC *
      ELSE.
        MODIFY extract INDEX meamt_index.
      ENDIF.
  ENDCASE.
  LOOP AT vim_collapsed_mainkeys.
    CHECK <vim_collapsed_mkey_bfx> EQ <vim_mkey_beforex>
     AND <vim_collapsed_keyx> NE <vim_xextract_key>.
*  LOOP AT vim_collapsed_mainkeys WHERE mkey_bf EQ <vim_mkey_before>
*                                   AND mainkey NE <vim_extract_key>.
    IF vim_mkey_after_exists NE space.
      CHECK <vim_collapsed_key_afx> EQ <vim_mkey_afterx>.
*      CHECK <vim_collapsed_key_af> EQ <vim_mkey_after>.
    ENDIF.
    <vim_collapsed_keyx> = <vim_xextract_key>.
*    vim_collapsed_mainkeys-mainkey = <vim_extract_key>.
* changed XB. 12.06.02  BCEK060520/BCEK060521 -------begin----------
    if <vim_collapsed_mkey_bfx> NE <vim_ext_mkey_beforex>.
      <vim_collapsed_mkey_bfx> = <vim_ext_mkey_beforex>.
*    vim_collapsed_mainkeys-mkey_bf = <vim_ext_mkey_before>.
    endif.
* changed XB. 12.06.02  BCEK060520/BCEK060521 ---------end-----------
    MODIFY vim_collapsed_mainkeys.
  ENDLOOP.
ENDFORM.                               "mod_extract_and_mainkey_tab.

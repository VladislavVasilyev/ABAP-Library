*---------------------------------------------------------------------*
*       FORM VIM_ASSIGN_MKEY_AFTER_2                                  *
*---------------------------------------------------------------------*
* assign symbols to after-date-part of mainkey part 2                 *
*---------------------------------------------------------------------*
FORM vim_assign_mkey_after_2 USING value(vama2_tabix) TYPE i.
  LOCAL:x_namtab.
  DATA: vama_ix TYPE i, keylen TYPE i, position TYPE i.
  FIELD-SYMBOLS: <x_namtab> TYPE vimnamtab.

  check vim_mkey_after_exists <> space.
  vama_ix = vama2_tabix + 1.
  READ TABLE x_namtab ASSIGNING <x_namtab> INDEX vama_ix.
  vama_ix = x_header-keylen - <x_namtab>-position.
  ASSIGN: <vim_xtotal>+<x_namtab>-position(vama_ix)
                            TO <vim_tot_mkey_afterx>,
          <vim_xextract>+<x_namtab>-position(vama_ix)
                            TO <vim_ext_mkey_afterx>.
  IF x_header-generictrp <> 'X'.
* charlike key or non-unicode-system (FS is only assigned for
* downward compatibility).
    keylen = x_header-keylen / cl_abap_char_utilities=>charsize.
    position = <x_namtab>-position / cl_abap_char_utilities=>charsize.
    vama_ix = keylen - position.
    ASSIGN: <vim_ctotal>+position(vama_ix)
                              TO <vim_tot_mkey_after> TYPE 'C',
            <vim_cextract>+position(vama_ix)
                              TO <vim_ext_mkey_after> TYPE 'C'.
  ELSE.
    ASSIGN: <vim_xtotal>+<x_namtab>-position(vama_ix)
             TO <vim_tot_mkey_after>,
            <vim_xextract>+<x_namtab>-position(vama_ix)
             TO <vim_ext_mkey_after>.
  ENDIF.
ENDFORM.                               "vim_assign_mkey_after_2

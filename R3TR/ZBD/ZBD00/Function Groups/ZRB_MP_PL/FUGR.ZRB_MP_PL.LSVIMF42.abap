*---------------------------------------------------------------------*
*       FORM VIM_ASSIGN_MAINKEY_AFTER                                 *
*---------------------------------------------------------------------*
* assign symbols to after-date-part of mainkey                        *
*---------------------------------------------------------------------*
FORM vim_assign_mainkey_after USING value(vama_tabix) TYPE i.
  DATA: vama_ix TYPE i, length TYPE i.
  FIELD-SYMBOLS: <x_namtab> TYPE vimnamtab.

  vama_ix = vama_tabix + 1.
  READ TABLE x_namtab ASSIGNING <x_namtab> INDEX vama_ix.
  IF sy-subrc EQ 0 AND                 "entry found and
   <x_namtab>-texttabfld EQ space AND  "key continues
   <x_namtab>-position LT x_header-keylen. "after date field
    vama_ix = x_header-keylen - <x_namtab>-position.
    ASSIGN: <table1_x>+<x_namtab>-position(vama_ix)
                              TO <vim_f1_afterx>,
            <vim_h_coll_mkey>+<x_namtab>-position(vama_ix)
                              TO <vim_collapsed_key_afx>,
            <vim_h_mkey>+<x_namtab>-position(vama_ix)
                              TO <vim_mkey_afterx>,
            <vim_h_old_mkey>+<x_namtab>-position(vama_ix)
                              TO <vim_old_mkey_afterx>. " TYPE 'C'.
    IF x_header-generictrp <> 'X'.
** charlike key or non-unicode-system (FS is only assigned for
** downward compatibility).
      length = <x_namtab>-position
                DIV cl_abap_char_utilities=>charsize.
      vama_ix = vama_ix DIV cl_abap_char_utilities=>charsize.
      ASSIGN: <table1>+length(vama_ix)
                                TO <vim_f1_after>,
              vim_collapsed_mainkeys-mainkey+length(vama_ix)
                                TO <vim_collapsed_key_af>,
              vim_mainkey+length(vama_ix)
                                TO <vim_mkey_after>,
              vim_old_viewkey+length(vama_ix)
                                TO <vim_old_mkey_after>.
    ELSE.
      ASSIGN: <vim_f1_afterx> TO <vim_f1_after>,
              <vim_collapsed_key_afx> TO <vim_collapsed_key_af>,
              <vim_mkey_afterx> TO <vim_mkey_after>,
              <vim_old_mkey_afterx> TO <vim_old_mkey_after>.
    ENDIF.
    vim_mkey_after_exists = 'X'.
    CLEAR vim_no_mainkey_exists.
  ELSE.
    CLEAR vim_mkey_after_exists.
  ENDIF.
ENDFORM.                               "vim_asign_mainkey_after

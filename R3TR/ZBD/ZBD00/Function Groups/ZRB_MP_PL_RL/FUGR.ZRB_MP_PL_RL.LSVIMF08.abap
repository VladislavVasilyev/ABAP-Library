*---------------------------------------------------------------------*
*       FORM VIM_SET_IMP_RESULTS                                      *
*---------------------------------------------------------------------*
* (re)set result of import for current entry                          *
*---------------------------------------------------------------------*
* VALUE(VSIR_KEY)    ---> key of current entry                        *
* VALUE(VSIR_ACTION) ---> action happened to current entry            *
*                         - GELOESCHT OR UPDATE_GELOESCHT -> deleted  *
*                         - AENDERN                       -> updated  *
*                         - NEUER_EINTRAG                 -> inserted *
*                         - ORIGINAL                      -> unchanged*
*                         - SLCTR_IMP_ERROR               -> error    *
*---------------------------------------------------------------------*
FORM vim_set_imp_results USING value(vsir_key)
                               value(vsir_action) LIKE tvdir-flag.
  DATA: vsir_xkey TYPE vim_tabkey_c, vsir_xkeylen TYPE i,
        vsir_rc TYPE i,
        vsir_ix TYPE i.

  PERFORM vim_set_impres_header.
  PERFORM vim_convert_tabkey USING vsir_key vsir_xkey vsir_xkeylen.
  imp_results-tabkey = vsir_xkey.
  READ TABLE imp_results WITH KEY objtab = imp_results-objtab
                                  tabkey = imp_results-tabkey.
  vsir_rc = sy-subrc. vsir_ix = sy-tabix.
  CLEAR imp_results-import.
  CASE vsir_action.
    WHEN geloescht OR update_geloescht.
      imp_results-import-deleted = 1.
    WHEN aendern.
      imp_results-import-updated = 1.
    WHEN neuer_eintrag.
      imp_results-import-inserted = 1.
    WHEN original.
      imp_results-import-unchanged = 1.
    WHEN OTHERS.
      imp_results-import-errors = 1.
  ENDCASE.
  IF vsir_rc NE 0.
    APPEND imp_results.
  ELSE.
    MODIFY imp_results INDEX vsir_ix.
  ENDIF.
ENDFORM.                               "vim_set_imp_reults

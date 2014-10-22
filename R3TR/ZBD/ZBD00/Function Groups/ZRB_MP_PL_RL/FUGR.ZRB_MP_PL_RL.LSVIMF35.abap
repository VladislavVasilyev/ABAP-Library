*---------------------------------------------------------------------*
*       FORM CHECK_AND_MODIFY_MAINKEY_TAB                             *
*---------------------------------------------------------------------*
* ...............                                                     *
*---------------------------------------------------------------------*
FORM check_and_modify_mainkey_tab USING cammt_rec.
  CHECK vim_ignore_collapsed_mainkeys EQ space.
  IF vim_no_mainkey_exists EQ vim_no_mkey_not_procsd OR
     <vim_tot_mkey_beforex> NE <vim_mkey_beforex> OR
     ( vim_mkey_after_exists NE space AND
       <vim_tot_mkey_afterx> NE <vim_mkey_afterx> ).
*     <vim_tot_mkey_before> NE <vim_mkey_before> OR
*     ( vim_mkey_after_exists NE space AND
*       <vim_tot_mkey_after> NE <vim_mkey_after> ).
    IF cammt_rec NE 9 AND cammt_rec NE 0.
      PERFORM mod_extract_and_mainkey_tab USING 'A' 0.
      CLEAR cammt_rec.
    ENDIF.
    <vim_h_mkey>(x_header-keylen) = <vim_xtotal_key>.
*    vim_mainkey = <vim_total_key>.
    extract = total. "this statement is necessary, do not delete it !!
    TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_procsd_patt.
  ELSE.
    CHECK cammt_rec NE 9 AND cammt_rec NE 0.
  ENDIF.
  PERFORM check_if_entry_is_to_display USING space <vim_xtotal_key>
                                             'X' <vim_begdate>.
  cammt_rec = sy-subrc.
ENDFORM.                               "modify_mainkey_tab

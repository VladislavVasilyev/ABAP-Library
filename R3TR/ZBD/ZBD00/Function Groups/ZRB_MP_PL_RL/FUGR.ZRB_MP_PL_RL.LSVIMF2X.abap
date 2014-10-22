*---------------------------------------------------------------------*
*       FORM CHECK_NEW_MAINKEY                                        *
*---------------------------------------------------------------------*
* check if current mainkey is a new one                               *
*---------------------------------------------------------------------*
* <-- SY-SUBRC : 0 -> mainkey is new, others -> mainkey already exists*
*---------------------------------------------------------------------*
FORM check_new_mainkey.
  LOCAL: total, <table1>.
  DATA: hf TYPE i, rec TYPE i.

  MOVE: <vim_xtotal_key> TO <f1_x>.
  READ TABLE total WITH KEY <f1_x> BINARY SEARCH TRANSPORTING NO FIELDS."#EC *
  IF sy-subrc EQ 0."new entry already inserted into TOTAL
    hf = sy-tabix - 1.
    READ TABLE total INDEX hf.         "read previous entry
    IF <vim_tot_mkey_beforex> EQ <vim_f1_beforex> AND
       ( vim_mkey_after_exists EQ space OR
         <vim_tot_mkey_afterx> EQ <vim_f1_afterx> ). "same mainkey
*    IF <vim_tot_mkey_before> EQ <vim_f1_before> AND
*       ( vim_mkey_after_exists EQ space OR
*         <vim_tot_mkey_after> EQ <vim_f1_after> ). "same mainkey
      rec = 8.                         "-> mainkey already exists
    ELSE. "not the same mainkey -> check also next entry
      hf = hf + 2.
      READ TABLE total INDEX hf.       "read next entry
      IF <vim_tot_mkey_beforex> EQ <vim_f1_beforex> AND
         ( vim_mkey_after_exists EQ space OR
           <vim_tot_mkey_afterx> EQ <vim_f1_afterx> ). "same mainkey
*      IF <vim_tot_mkey_before> EQ <vim_f1_before> AND
*         ( vim_mkey_after_exists EQ space OR
*           <vim_tot_mkey_after> EQ <vim_f1_after> ). "same mainkey
        rec = 8.                       "-> mainkey already exists
      ENDIF.
    ENDIF.
  ENDIF.
  sy-subrc = rec.
ENDFORM.                               "check_new_mainkey

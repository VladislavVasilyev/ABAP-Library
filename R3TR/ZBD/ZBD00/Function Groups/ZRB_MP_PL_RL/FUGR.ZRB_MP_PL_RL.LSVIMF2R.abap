*---------------------------------------------------------------------*
*       FORM CHECK_IF_ENTRY_CAN_BE_DELETED                            *
*---------------------------------------------------------------------*
* check if entry of existency-M-table/view can be deleted             *
*---------------------------------------------------------------------*
* SY_SUBRC <-- 0: yes, deleteable, others: no, not deleteable         *
*---------------------------------------------------------------------*
FORM check_if_entry_can_be_deleted.
  LOCAL: <f1_x>, total, <vim_xextract_key>.
  DATA: hf TYPE i, rec TYPE i VALUE 8.

  <vim_xextract_key> = <f1_x> = <vim_xtotal_key>.
  CLEAR <vim_enddate_mask>.
  READ TABLE total WITH KEY <f1_x> BINARY SEARCH TRANSPORTING NO FIELDS."#EC *
  hf = sy-tabix.
  LOOP AT total FROM hf.
    IF <vim_tot_mkey_beforex> NE <vim_f1_beforex> OR
       ( vim_mkey_after_exists NE space AND
         <vim_tot_mkey_afterx> NE <vim_f1_afterx> ).
*    IF <vim_tot_mkey_before> NE <vim_f1_before> OR
*       ( vim_mkey_after_exists NE space AND
*         <vim_tot_mkey_after> NE <vim_f1_after> ).
      EXIT.
    ENDIF.
    CHECK <action> NE geloescht AND <action> NE neuer_geloescht AND
          <action> NE update_geloescht AND
          <vim_xtotal_key> NE <vim_xextract_key>.
    CLEAR rec. EXIT.
  ENDLOOP.
  sy-subrc = rec.
ENDFORM.                               "check_if_entry_can_be_deleted

*&--------------------------------------------------------------------*
*&      Form  CHECK_MODIFY_MERGED_ENTRIES                             *
*&--------------------------------------------------------------------*
* check if changed entry is to be merged and if so do it
* merging functionality has never been finished                       *
*&--------------------------------------------------------------------*
* <-- SY-SUBRC: 0 - ok, merge, others: don't merge                    *
*&--------------------------------------------------------------------*
*FORM CHECK_MODIFY_MERGED_ENTRIES USING VALUE(ENTRY_IN).
*  LOCAL: TOTAL, <TABLE1>.
*  DATA: REC TYPE I VALUE 8.
*  <F1> = ENTRY_IN. <VIM_ENDDATE_MASK> = VIM_DATE_MASK.
*  LOOP AT VIM_MERGED_ENTRIES WHERE NEW_KEY CP <F1>. "Achtung !!!!!!
*    READ TABLE TOTAL WITH KEY VIM_MERGED_ENTRIES-MERGED_KEY
*                     BINARY SEARCH.
*    IF SY-SUBRC EQ 0.
*      <TABLE1> = TOTAL.
*      <VIM_BEGDATE_MASK> = VIM_DATE_MASK.
*      <VIM_ENDDATE_MASK> = VIM_DATE_MASK.
*      IF ENTRY_IN CP <TABLE1>. "entry can be merged. "ACHTUNG!!
*        CLEAR REC.
*        TOTAL = ENTRY_IN.
*        VIM_MERGED_ENTRIES-MERGED_KEY = <VIM_TOTAL_KEY>.
*
*
*
*
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                               "check_modify_merged_entries

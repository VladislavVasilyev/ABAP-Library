*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZRB_MP_PL
*   generation date: 11.11.2014 at 11:04:12 by user AKOZIN00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZRB_MP_PL          .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

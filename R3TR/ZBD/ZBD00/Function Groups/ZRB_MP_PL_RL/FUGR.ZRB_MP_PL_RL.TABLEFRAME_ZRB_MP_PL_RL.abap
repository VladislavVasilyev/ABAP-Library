*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZRB_MP_PL_RL
*   generation date: 24.07.2014 at 16:25:06 by user AKOZIN00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZRB_MP_PL_RL       .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

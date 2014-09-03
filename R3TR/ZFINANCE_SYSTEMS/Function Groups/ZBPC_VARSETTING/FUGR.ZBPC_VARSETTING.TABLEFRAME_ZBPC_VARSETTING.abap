*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBPC_VARSETTING
*   generation date: 20.02.2013 at 10:03:45 by user VVASILYEV00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBPC_VARSETTING    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

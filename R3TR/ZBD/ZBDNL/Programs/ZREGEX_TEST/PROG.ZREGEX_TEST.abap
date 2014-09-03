*&---------------------------------------------------------------------*
*& Report  ZREGEX_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREGEX_TEST.


IF 1 = 1 AND 1 = 1 OR 1 = 1 .

BREAK-POINT.
ENDIF.

  DATA
  : GD_V__EXP1 TYPE STRING VALUE `MASTER TABL_ENAME PACKAGE SIZE 50000`
  , GD_V__EXP2 TYPE STRING VALUE `MASTER TABLENAME FROM DAA`
  , GD_V__EXP3 TYPE STRING VALUE `TABLENAME`
  , LD_T__RESULTS   TYPE MATCH_RESULT_TAB

  .

  FIND FIRST OCCURRENCE OF REGEX `\<(MASTER)\>\s\<([A-Z0-9\_]+)\>\s\<(PACKAGE\sSIZE)\>\s([0-9]+)\>` IN GD_V__EXP1.

  BREAK-POINT.

  FIND FIRST OCCURRENCE OF REGEX `\<(SAVE|MASTER)\>\s\<([A-Z0-0\_]+)\>` IN GD_V__EXP2.

  BREAK-POINT.

  DATA
  : GD_V__EXP4 TYPE STRING VALUE `PRODUCT ~ CATEGORY = '"ASD"'`
  , GD_V__EXP5 TYPE STRING VALUE `'PRODUCT' = 'ASD'`
  , GD_V__EXP6 TYPE STRING VALUE ` DEMO`" /DEMO_01/NEW_LOGIC.LGF`
  , GD_V__EXP7 TYPE STRING VALUE ` -123 + 234 * -345`
  .

*  find first occurrence of regex `\<([A-Z0-9\_]+)\>` in gd_v__exp4.
  FIND ALL OCCURRENCES OF REGEX `(\-\d+|\<\d+)` IN GD_V__EXP7 RESULTS LD_T__RESULTS.
*  find all occurrences of regex `\<(-(\d+)|\d+)` in gd_v__exp7 results ld_t__results.

*  break-point.
*
*  find first occurrence of regex `\<([A-Z0-9\_]+)\>\s\~\s\<([A-Z0-9\_]+)\>` in gd_v__exp4.
*
*  break-point.
*
*  find first occurrence of regex `'([A-Z]+)'` in gd_v__exp5.
*
*  break-point.

* find first occurrence of regex `\s(EQ|=)\s` in gd_v__exp5.

*\/([A-Z0-9\__]+)\/([A-Z0-9\__]+)\.LGF\
    FIND FIRST OCCURRENCE OF REGEX `([A-Z0-9\_]+)` IN GD_V__EXP6 IGNORING CASE.

      DATA A TYPE P.
      A = '-1.3' + '-34'*'-123'/'-1.5' .



 BREAK-POINT.

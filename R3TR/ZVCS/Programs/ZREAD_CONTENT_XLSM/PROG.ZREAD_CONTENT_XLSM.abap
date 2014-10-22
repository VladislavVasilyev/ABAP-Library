*&---------------------------------------------------------------------*
*& Report  ZREAD_CONTENT_XLSM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREAD_CONTENT_XLSM.


DATA: O_PACK_DOC TYPE REF TO CL_DOCX_DOCUMENT.
DATA: LD_V__CONTENT TYPE UJF_DOC-DOC_CONTENT.


SELECT SINGLE DOC_CONTENT
  FROM UJF_DOC
  INTO LD_V__CONTENT
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\DEMO\DEMO_01\EEXCEL\DIMENSIONS\CURRENCY.XML`.

BREAK-POINT.

  O_PACK_DOC = CL_DOCX_DOCUMENT=>LOAD_DOCUMENT( IV_DATA = LD_V__CONTENT ).

  BREAK-POINT.

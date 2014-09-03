*&---------------------------------------------------------------------*
*& Report  ZREAD_LGF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREAD_LGF.

DATA: P_STRING TYPE STRING VALUE 'ABC##DE##F#G',
      L1 TYPE I,
      L2 TYPE C,
      L3 TYPE STRING,
      L4(2) TYPE C VALUE '  ' .

L1 = STRLEN( P_STRING ).
DO L1 TIMES.
L1 = L1 - 1.
L2 = P_STRING+L1(1).

IF L2 CA 'QWERTYUIOPLKJHGFDSAZXCVBNM0987654321 '.
   CONCATENATE L2 L3 INTO L3.
ELSE.
  REPLACE L2 WITH L4 INTO L2.
  CONCATENATE L2 L3 INTO L3 SEPARATED BY SPACE.
ENDIF.
ENDDO.
WRITE: L3.







*DATA: hex1(1)  TYPE x VALUE 'A0'.
*DATA: hex2(1)  TYPE x VALUE '20'.
*DATA: uhex1(2) TYPE x VALUE '00A0'.
*DATA: uhex2(2) TYPE x VALUE '0020'.
*DATA: char1(1) TYPE c.
*
*DATA: test_string TYPE string VALUE 'Stuff in here'.
*DATA: test_xstring TYPE xstring.
*DATA:
*  convin  TYPE REF TO cl_abap_conv_in_ce.
*
*data s type string.
*
*
*concatenate cl_abap_char_utilities=>HORIZONTAL_TAB `A` cl_abap_char_utilities=>HORIZONTAL_TAB into s.
*
*CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
*  EXPORTING
*    text   = s
*  IMPORTING
*    buffer = test_xstring.
*
*
*CALL METHOD cl_abap_conv_in_ce=>create
*  EXPORTING
*    input = test_xstring
*  RECEIVING
*    conv  = convin.
*
*CALL METHOD convin->read
*  IMPORTING
*    data = s.
*
*write s." as symbol.
*
*
*
*break-point.
*
*
*
*****Convert the Character String to Binary String
*CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
*  EXPORTING
*    text   = test_string
*  IMPORTING
*    buffer = test_xstring.
*
*break-point.
*
*IF cl_abap_char_utilities=>charsize = 1.
*  REPLACE ALL OCCURENCES OF hex1 IN test_xstring WITH hex2 IN BYTE MODE.
*ELSE.
*  REPLACE ALL OCCURENCES OF uhex1 IN test_xstring WITH uhex2 IN BYTE MODE.
*ENDIF.
*
*CLEAR test_string.
*
*
*CALL METHOD cl_abap_conv_in_ce=>create
*  EXPORTING
*    input = test_xstring
*  RECEIVING
*    conv  = convin.
*
*CALL METHOD convin->read
*  IMPORTING
*    data = test_string.
*
*WRITE: / test_string.

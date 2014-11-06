*&---------------------------------------------------------------------*
*& Report  ZDEL_LGF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZDEL_LGF.


FIELD-SYMBOLS: <ANY> TYPE ANY.
DATA A TYPE P LENGTH 7 DECIMALS 11 .
DATA S TYPE C LENGTH 255.

ASSIGN A TO <ANY>.


A = ABS( `123.567` ).

*write <any> to s.

BREAK-POINT.


*delete from ujf_doc where appset = `BUDGET_2015` and doctype = `LGF`.

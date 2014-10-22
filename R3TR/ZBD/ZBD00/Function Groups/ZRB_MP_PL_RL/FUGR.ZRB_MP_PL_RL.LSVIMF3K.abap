*---------------------------------------------------------------------*
*       FORM BLAETTERN                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM BLAETTERN.
  DATA: B_OVERLAPPING(1) TYPE C VALUE 'X'.
  IF MAXLINES EQ 0.
    EXIT.
  ENDIF.
  IF STATUS-ACTION EQ KOPIEREN OR LOOPLINES EQ 1.
    CLEAR B_OVERLAPPING.
  ENDIF.
  CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
            ENTRY_TO       = MAXLINES
            LOOPS          = LOOPLINES
            OK_CODE        = FUNCTION
            ENTRY_ACT      = FIRSTLINE
            LAST_PAGE_FULL = ' '
*           OVERLAPPING    = 'X'
            OVERLAPPING    = B_OVERLAPPING
       IMPORTING
            ENTRY_NEW      = NEXTLINE.
ENDFORM.

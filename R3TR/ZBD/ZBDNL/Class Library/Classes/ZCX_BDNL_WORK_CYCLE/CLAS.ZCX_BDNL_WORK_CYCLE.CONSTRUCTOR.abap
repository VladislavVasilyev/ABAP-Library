method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->PACKAGE = PACKAGE .
me->LINE = LINE .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_BDNL_WORK_CYCLE .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.
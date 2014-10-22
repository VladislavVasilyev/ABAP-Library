*---------------------------------------------------------------------*
*       FORM X_ENQUEUE                                                *
*---------------------------------------------------------------------*
* enqueue view (external call)                                        *
*---------------------------------------------------------------------*
* XE_SELLIST       ---> table of selection conditions for view/table  *
* VALUE(XE_NAME)   ---> name of view/table to process                 *
* VALUE(XE_ACT)    ---> action: E -> enqueue, D -> dequeue            *
* VALUE(EXIT_FORM) ---> name of exit form to process after enqueue    *
* VALUE(XE_ENQRNG) ---> flag: X -> enqueue range, ' ' -> full table   *
*---------------------------------------------------------------------*
FORM X_ENQUEUE TABLES XE_SELLIST STRUCTURE VIMSELLIST
               USING VALUE(XE_NAME) VALUE(XE_ACT) VALUE(EXIT_FORM)
                     VALUE(XE_ENQRNG).
  DATA: VIEWNAME_SAFE LIKE VIMDESC-VIEWNAME, ENQ_RANGE_SAFE(1) TYPE C.

  VIEWNAME_SAFE = VIM_VIEW_NAME. ENQ_RANGE_SAFE = VIM_ENQUEUE_RANGE.
  VIM_VIEW_NAME = XE_NAME. VIM_ENQUEUE_RANGE = XE_ENQRNG.
  ASSIGN XE_SELLIST-*SYS* TO <VIM_SELLIST>.
  PERFORM ENQUEUE USING XE_ACT EXIT_FORM.
  VIM_VIEW_NAME = VIEWNAME_SAFE. VIM_ENQUEUE_RANGE = ENQ_RANGE_SAFE.
ENDFORM.

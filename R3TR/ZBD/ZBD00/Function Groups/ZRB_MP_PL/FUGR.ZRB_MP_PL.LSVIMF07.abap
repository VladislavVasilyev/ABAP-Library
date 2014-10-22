*---------------------------------------------------------------------*
*       FORM VIM_SINGLE_ENTRY_FILL_SELLIST                            *
*---------------------------------------------------------------------*
* fill sellist in case of single entry maintenance                    *
*---------------------------------------------------------------------*
FORM vim_single_entry_fill_sellist.
  DATA: countx TYPE i, nam_ix TYPE i.
  FIELD-SYMBOLS: <h1>.

  LOOP AT x_namtab WHERE keyflag NE space AND texttabfld EQ space.
    CHECK x_header-clidep EQ space OR sy-tabix GT 1.
    nam_ix = sy-tabix.
    assign component x_namtab-viewfield of structure <table1> to <h1>.
*    ASSIGN <TABLE1>+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH) TO <H1>.
    READ TABLE dpl_sellist WITH KEY viewfield = x_namtab-viewfield
                                    operator  = 'EQ'
                                    negation  = space.
    IF sy-subrc NE 0.
      CLEAR dpl_sellist.
      dpl_sellist-viewfield = x_namtab-viewfield.
      dpl_sellist-operator  = 'EQ'.
      dpl_sellist-and_or    = 'AND'.
      dpl_sellist-tabix     = nam_ix.
      APPEND dpl_sellist.
    ENDIF.
    countx = sy-tabix. CLEAR dpl_sellist-converted.
    dpl_sellist-ddic = 'S'. CLEAR dpl_sellist-value.
    CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
         EXPORTING
              value_intern = <h1>
              tabname      = x_header-maintview
              fieldname    = x_namtab-viewfield
*              inttype      = x_namtab-inttype
*              datatype     = x_namtab-datatype
*              decimals     = x_namtab-decimals
*              convexit     = x_namtab-convexit
*              sign         = x_namtab-sign
              outputlen    = x_namtab-outputlen
              intlen       = x_namtab-flength
         IMPORTING
              value_extern = dpl_sellist-value.
    IF dpl_sellist-value EQ space.
      dpl_sellist-initial = 'X'.
    ELSE.
      CLEAR dpl_sellist-initial.
    ENDIF.
    MODIFY dpl_sellist INDEX countx.
    x_namtab-readonly = 'S'. MODIFY x_namtab.
  ENDLOOP.
  ASSIGN dpl_sellist[] TO <vim_ck_sellist>.
  x_header-subsetflag = x_header-selection = 'X'.
  MODIFY x_header INDEX 1.
  PERFORM init_subset_keyfields.
ENDFORM.                               "vim_single_entry_fill_sellist

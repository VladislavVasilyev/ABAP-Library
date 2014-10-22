*&---------------------------------------------------------------------*
*&  Include           LSVIMF65                                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_nonkey
*&---------------------------------------------------------------------*
*       to check selection condiotions for nonkey fields only
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM check_nonkey.


  FIELD-SYMBOLS: <table1_txt_loc> TYPE ANY.


  IF x_header-bastab <> space AND x_header-texttbexst <> space.
    ASSIGN <table1_text> TO <table1_txt_loc>.
  ELSE.
    ASSIGN <table1> TO <table1_txt_loc>.
  ENDIF.
  CALL FUNCTION 'TABLE_RANGE_CHECK'
    EXPORTING
      tabname                   = x_header-maintview
      entry                     = <table1>
      entry_text                = <table1_txt_loc>
      ddic                      = 'J'
      key                       = 'F'
      ignore_blank_subsetfields = 'N'
    TABLES
      x_namtab                  = x_namtab
      x_header                  = x_header
      sellist                   = <vim_ck_sellist>
    EXCEPTIONS
      entry_not_fits            = 1.
  IF sy-subrc EQ 1.
*    PERFORM set_pf_status USING 'ERROR'.
    MESSAGE w174(sv).
  ENDIF.
ENDFORM.        "check_nonkey

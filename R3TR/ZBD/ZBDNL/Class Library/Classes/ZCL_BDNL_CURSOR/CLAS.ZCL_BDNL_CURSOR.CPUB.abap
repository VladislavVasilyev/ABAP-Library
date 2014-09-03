class ZCL_BDNL_CURSOR definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_CURSOR
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZBLNC .
  type-pools ZBNLT .

  data GD_V__INDEX type I read-only .
  data GD_V__SCRIPT_PATH type STRING read-only .
  data GD_F__END type RS_BOOL read-only .
  data GD_V__CTOKEN type STRING read-only .
  data GD_V__CINDEX type I read-only .

  methods CHECK_LETTER
    returning
      value(E) type RS_BOOL .
  methods CREATE_TOKEN
    raising
      ZCX_BDNL_EXCEPTION .
  methods CHECK_NUM
    returning
      value(E) type RS_BOOL .
  methods CHECK_TOKENS
    importing
      !REGEX type STRING
      !Q type I default 1
      !F_NOSPACE type RS_BOOL default ABAP_FALSE
    returning
      value(CHECK) type RS_BOOL .
  methods CHECK_VARIABLE
    returning
      value(E) type RS_BOOL .
  methods CONSTRUCTOR
    importing
      !I_T__VARIABLE type ZBNLT_T__VARIABLE
      !I_V__APPSET type UJ_APPSET_ID
      !I_V__APPLICATION type UJ_APPL_ID
      !I_V__FILENAME type UJ_DOCNAME
    raising
      ZCX_BDNL_EXCEPTION .
  methods GET_SCRIPT_LINE
    importing
      !INDEX type I
    exporting
      value(LINE) type STRING
      !MATCH type ZBNLT_S__MATCH_RES .
  methods GET_TOKEN
    importing
      !ESC type RS_BOOL optional
      !TRN type I optional
      !CHN type RS_BOOL optional
    returning
      value(TOKEN) type STRING
    raising
      ZCX_BDNL_EXCEPTION .
  methods GET_TOKENS
    importing
      !Q type I default 1
      !F_NOSPACE type RS_BOOL default ABAP_FALSE
    returning
      value(TOKENS) type STRING .
  class-methods READ_LOGIC
    importing
      !I_V__APPSET type UJ_APPSET_ID
      !I_V__APPLICATION type UJ_APPL_ID
      !I_V__FILENAME type UJ_DOCNAME
    exporting
      !E_T__LOGIC type ZBNLT_T__LGFSOURCE
      !E_S__DOC type UJF_DOC .
  methods SET_CURSOR
    importing
      !WORD type STRING
      !ESCAPE type STRING optional
      !FESC type RS_BOOL optional
    returning
      value(INDEX) type I .
  methods SET_TOKEN_POS
    importing
      !INDEX type I .
  methods _DEL_CHECK_NAME
    raising
      ZCX_BDNL_EXCEPTION .
  methods _DEL_GET_INDEX_POS
    importing
      !INDEX type I
    returning
      value(MATCH) type ZBNLT_S__MATCH_RES .
  methods _DEL_GET_TOKEN_POS
    returning
      value(INDEX) type I .
  methods _DEL_NEXT_TOKEN
    returning
      value(INDEX) type I .

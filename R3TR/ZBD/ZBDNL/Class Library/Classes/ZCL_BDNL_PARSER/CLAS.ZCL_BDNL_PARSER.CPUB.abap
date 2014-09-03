class ZCL_BDNL_PARSER definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_PARSER
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZBLNC .
  type-pools ZBNLT .

  types:
    begin of ty_s__if
            , token type string
            , type  type string
            , end of ty_s__if .
  types:
    begin of ty_s__filterpools
             , appset_id type uj_appset_id
             , appl_id   type uj_appl_id
             , script    type uj_docname
             , end of ty_s__filterpools .
  types:
    ty_t__filterpools type hashed table of ty_s__filterpools with unique default key .

  constants:
    true type c length 1 value `1`. "#EC NOTEXT
  constants:
    false type c length 1 value `0`. "#EC NOTEXT

  methods GET_STACK
    returning
      value(STACK) type ZBNLT_S__STACK
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CONSTRUCTOR
    importing
      !I_V__APPSET type UJ_APPSET_ID
      !I_V__APPLICATION type UJ_APPL_ID
      !I_V__FILENAME type UJ_DOCNAME
      !I_T__VARIABLE type ZBNLT_T__VARIABLE
    raising
      ZCX_BDNL_EXCEPTION .

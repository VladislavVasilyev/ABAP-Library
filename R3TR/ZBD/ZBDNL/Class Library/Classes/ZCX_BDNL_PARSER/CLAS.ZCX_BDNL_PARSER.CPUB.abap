class ZCX_BDNL_PARSER definition
  public
  inheriting from ZCX_BDNL_EXCEPTION
  final
  create public .

*"* public components of class ZCX_BDNL_PARSER
*"* do not include other source files here!!!
public section.

  type-pools ZBNLT .
  data ERRORTAB type ZBNLT_T__STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !ERRORTAB type ZBNLT_T__STRING optional .

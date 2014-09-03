class ZCX_BDNL_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

*"* public components of class ZCX_BDNL_EXCEPTION
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .

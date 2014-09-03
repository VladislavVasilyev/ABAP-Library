class ZCX_BD00_READ_DATA definition
  public
  inheriting from ZCX_BD00_STATIC_EXCEPTION
  final
  create public .

*"* public components of class ZCX_BD00_READ_DATA
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .

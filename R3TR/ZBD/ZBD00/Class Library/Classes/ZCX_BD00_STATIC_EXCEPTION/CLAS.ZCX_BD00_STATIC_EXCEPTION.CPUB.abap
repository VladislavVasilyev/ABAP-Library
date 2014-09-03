class ZCX_BD00_STATIC_EXCEPTION definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

*"* public components of class ZCX_BD00_STATIC_EXCEPTION
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_BD00_STATIC_EXCEPTION,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_BD00_STATIC_EXCEPTION .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .

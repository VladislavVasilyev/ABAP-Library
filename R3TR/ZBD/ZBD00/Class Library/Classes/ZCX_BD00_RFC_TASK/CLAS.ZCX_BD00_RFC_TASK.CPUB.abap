class ZCX_BD00_RFC_TASK definition
  public
  inheriting from ZCX_BD00_STATIC_EXCEPTION
  final
  create public .

*"* public components of class ZCX_BD00_RFC_TASK
*"* do not include other source files here!!!
public section.

  constants:
    begin of ZCX_BD00_RFC_TASK,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '008',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_BD00_RFC_TASK .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .

class ZCX_BDNL_WORK_RULE definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_BDNL_WORK_RULE
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_BDNL_WORK_RULE,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '067',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_BDNL_WORK_RULE .
  constants:
    begin of ZCX_EXCEED_36,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '066',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_EXCEED_36 .
  constants:
    begin of ZCX_GENERATE_ERROR,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '068',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_GENERATE_ERROR .
  class-data PACKAGE type I .
  class-data LINE type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !PACKAGE type I optional
      !LINE type STRING optional .

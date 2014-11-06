class ZCX_BDNL_WORK_FUNC definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_BDNL_WORK_FUNC
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_BDNL_WORK_FUNC,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '060',
      attr1 type scx_attrname value 'NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_BDNL_WORK_FUNC .
  class-data NAME type STRING .
  type-pools ABAP .
  data BINDPARAM type ABAP_PARMBIND_TAB .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !NAME type STRING optional
      !BINDPARAM type ABAP_PARMBIND_TAB optional .

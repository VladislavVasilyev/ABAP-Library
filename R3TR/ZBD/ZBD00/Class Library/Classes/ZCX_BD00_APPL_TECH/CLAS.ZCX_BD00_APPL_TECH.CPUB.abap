class ZCX_BD00_APPL_TECH definition
  public
  inheriting from ZCX_BD00_STATIC_EXCEPTION
  final
  create public .

*"* public components of class ZCX_BD00_APPL_TECH
*"* do not include other source files here!!!
public section.

  constants:
    begin of CX_DRPINDEX_ERORR,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'GD_V__APPL_ID',
      attr2 type scx_attrname value 'GD_V__APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CX_DRPINDEX_ERORR .
  constants:
    begin of CX_INDEX_ERORR,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'GD_V__APPL_ID',
      attr2 type scx_attrname value 'GD_V__APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CX_INDEX_ERORR .
  constants:
    begin of CX_DBSTAT_ERORR,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'GD_V__APPL_ID',
      attr2 type scx_attrname value 'GD_V__APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CX_DBSTAT_ERORR .
  data GD_V__APPSET_ID type UJ_APPSET_ID .
  data GD_V__APPL_ID type UJ_APPL_ID .
  data GD_V__INFOPROVIDE type RSINFOPROV .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !GD_V__APPSET_ID type UJ_APPSET_ID optional
      !GD_V__APPL_ID type UJ_APPL_ID optional
      !GD_V__INFOPROVIDE type RSINFOPROV optional .

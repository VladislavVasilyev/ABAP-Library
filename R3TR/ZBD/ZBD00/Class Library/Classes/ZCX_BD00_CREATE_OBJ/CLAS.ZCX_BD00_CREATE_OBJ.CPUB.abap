class ZCX_BD00_CREATE_OBJ definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_BD00_CREATE_OBJ
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_BD00_CREATE_OBJ,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_BD00_CREATE_OBJ .
  constants:
    begin of EX_APPL_NOT_FOUND,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'I_APPL_ID',
      attr2 type scx_attrname value 'I_APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_APPL_NOT_FOUND .
  constants:
    begin of EX_APPSET_NOT_FOUND,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'I_APPSET_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_APPSET_NOT_FOUND .
  constants:
    begin of EX_INFOPROV_NOT_FOUND,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'I_INFOPROVIDE',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_INFOPROV_NOT_FOUND .
  constants:
    begin of EX_DIM_NOT_FOUND,
      msgid type symsgid value 'ZBD00',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'I_DIM_NAME',
      attr2 type scx_attrname value 'I_APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_DIM_NOT_FOUND .
  data I_APPSET_ID type UJ_APPSET_ID .
  data I_APPL_ID type UJ_APPL_ID .
  data I_INFOPROVIDE type RSINFOPROV .
  data I_DIM_NAME type UJ_DIM_NAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !I_INFOPROVIDE type RSINFOPROV optional
      !I_DIM_NAME type UJ_DIM_NAME optional .

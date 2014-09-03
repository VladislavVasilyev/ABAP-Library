class ZCX_VCS_OBJECTS_CREATE__R3TR definition
  public
  inheriting from ZCX_VCS_OBJECTS_CREATE
  final
  create public .

*"* public components of class ZCX_VCS_OBJECTS_CREATE__R3TR
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_VCS_OBJECTS_CREATE__R3TR,
      msgid type symsgid value 'ZMCL_VCS',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'OBJECT',
      attr2 type scx_attrname value 'OBJ_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_VCS_OBJECTS_CREATE__R3TR .
  constants:
    begin of CX_ALREADY_EXISTS,
      msgid type symsgid value 'ZMCL_VCS',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'OBJECT',
      attr2 type scx_attrname value 'OBJ_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CX_ALREADY_EXISTS .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !PGMID type PGMID optional
      !OBJECT type TROBJTYPE optional
      !OBJ_NAME type STRING optional .

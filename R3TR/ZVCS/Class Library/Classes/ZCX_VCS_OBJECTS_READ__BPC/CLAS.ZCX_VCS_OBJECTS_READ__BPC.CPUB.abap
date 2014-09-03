class ZCX_VCS_OBJECTS_READ__BPC definition
  public
  inheriting from ZCX_VCS_OBJECTS_READ
  final
  create public .

*"* public components of class ZCX_VCS_OBJECTS_READ__BPC
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_VCS_OBJECTS_READ__BPC,
      msgid type symsgid value 'ZMCL_VCS',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'OBJECT',
      attr2 type scx_attrname value 'OBJ_NAME',
      attr3 type scx_attrname value 'APPSET_ID',
      attr4 type scx_attrname value 'APPLICATION_ID',
    end of ZCX_VCS_OBJECTS_READ__BPC .
  data SYSTEM type STRING value 'BPC'. "#EC NOTEXT .
  data APPSET_ID type UJ_APPSET_ID .
  data APPLICATION_ID type UJ_APPL_ID .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !PGMID type PGMID optional
      !OBJECT type TROBJTYPE optional
      !OBJ_NAME type STRING optional
      !SYSTEM type STRING default 'BPC'
      !APPSET_ID type UJ_APPSET_ID optional
      !APPLICATION_ID type UJ_APPL_ID optional .

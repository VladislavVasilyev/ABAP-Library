class ZCX_VCS_OBJECTS_CREATE definition
  public
  inheriting from ZCX_VCS_OBJECTS
  create public .

*"* public components of class ZCX_VCS_OBJECTS_CREATE
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !PGMID type PGMID optional
      !OBJECT type TROBJTYPE optional
      !OBJ_NAME type STRING optional .

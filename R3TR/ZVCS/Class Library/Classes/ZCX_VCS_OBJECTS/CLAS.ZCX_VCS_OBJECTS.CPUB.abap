class ZCX_VCS_OBJECTS definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

*"* public components of class ZCX_VCS_OBJECTS
*"* do not include other source files here!!!
public section.

  data PGMID type PGMID .
  data OBJECT type TROBJTYPE .
  data OBJ_NAME type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !PGMID type PGMID optional
      !OBJECT type TROBJTYPE optional
      !OBJ_NAME type STRING optional .

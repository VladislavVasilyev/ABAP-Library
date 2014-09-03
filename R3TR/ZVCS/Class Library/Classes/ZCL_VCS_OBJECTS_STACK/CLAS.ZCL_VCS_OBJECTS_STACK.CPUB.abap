class ZCL_VCS_OBJECTS_STACK definition
  public
  abstract
  create public

  global friends ZCL_VCS_OBJECTS .

*"* public components of class ZCL_VCS_OBJECTS_STACK
*"* do not include other source files here!!!
public section.
  type-pools ZVCSC .
  type-pools ZVCST .

  constants CS_TIME_ZONE type TTZZ-TZONE value 'RUS03'. "#EC NOTEXT

  class-methods CHECK_TYPE
    importing
      !TYPE type ZVCST_S__OBJECT
    returning
      value(CHECK) type RS_BOOL .
  class-methods CLASS_CONSTRUCTOR .

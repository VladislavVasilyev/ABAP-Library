class ZCL_PATH_UTILITES definition
  public
  final
  create public .

*"* public components of class ZCL_PATH_UTILITES
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  class-methods CHECK_DIRECTORY
    importing
      !DIRECTORY type STRING
    returning
      value(CHECK) type RS_BOOL .
  class-methods GET_INITIAL_DIRECTORY
    returning
      value(DIRECTORY) type STRING .
  class-methods FILE_F4
    returning
      value(FILE) type STRING .
  class-methods DIRECTORY_F4
    returning
      value(DIRECTORY) type STRING .

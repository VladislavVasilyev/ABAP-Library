class ZCL_DEBUG definition
  public
  final
  create private .

*"* public components of class ZCL_DEBUG
*"* do not include other source files here!!!
public section.
  type-pools ZCONS .

  type-pools ABAP .
  class-data ON type ABAP_BOOL .
  class-data TIME type TIMESTAMPL .

  class-methods BREAK_POINT .
  class-methods CLASS_CONSTRUCTOR .
  class-methods STOP_PROGRAM
    importing
      !ON type ABAP_BOOL default ABAP_TRUE .

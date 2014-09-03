class ZCL_VCS__R3TR__DEVC definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__DEVC
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__devc
           , name  type devclass
           , tdevc type tdevc
           , end of ty_s__devc .

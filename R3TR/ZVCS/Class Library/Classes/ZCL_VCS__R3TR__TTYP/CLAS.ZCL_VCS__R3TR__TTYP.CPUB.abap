class ZCL_VCS__R3TR__TTYP definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__TTYP
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__ttyp
    , name      type ddobjname
    , gotstate  type ddgotstate
    , dd40v_wa  type dd40v
    , dd42v_tab type standard table of dd42v with non-unique default key
    , end of ty_s__ttyp .

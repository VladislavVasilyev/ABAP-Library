class ZCL_VCS__R3TR__DTEL definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__DTEL
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__dtel
    , name     type ddobjname
    , gotstate type  ddgotstate
    , dd04v_wa type  dd04v
    , tpara_wa type  tpara
    , end of ty_s__dtel .

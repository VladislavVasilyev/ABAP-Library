class ZCL_VCS__R3TR__DOMA definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__DOMA
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__doma
    , name        type ddobjname
    , gotstate    type ddgotstate
    , dd01v_wa    type dd01v
    , dd07v_tab   type standard table of dd07v with non-unique default key
    , end of ty_s__doma .

class ZCL_VCS__R3TR__SHLP definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__SHLP
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__shlp
    , name      type  ddobjname
    , gotstate  type  ddgotstate
    , dd30v_wa  type  dd30v
    , dd31v_tab type standard table of dd31v with non-unique default key
    , dd32p_tab type standard table of dd32p with non-unique default key
    , dd33v_tab type standard table of dd33v with non-unique default key
    , end of ty_s__shlp .

class ZCL_VCS__R3TR__VIEW definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__VIEW
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__view
      , name type  ddobjname
      , gotstate type ddgotstate
      , dd25v_wa type dd25v
      , dd09l_wa type dd09v
      , dd26v_tab type standard table of dd26v with non-unique default key
      , dd27p_tab type standard table of dd27p with non-unique default key
      , dd28j_tab type standard table of dd28j with non-unique default key
      , dd28v_tab type standard table of dd28v with non-unique default key
      , end of ty_s__view .

class ZCL_VCS__R3TR__TABL definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__TABL
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__tabl
      , name      type ddobjname
      , tabclass  type dd02l-tabclass
      , gotstate  type ddgotstate
      , dd02v_wa  type dd02v
      , dd09l_wa  type dd09v
      , dd03p_tab type standard table of dd03p with non-unique default key
      , dd05m_tab type standard table of dd05m with non-unique default key
      , dd08v_tab type standard table of dd08v with non-unique default key
      , dd12v_tab type standard table of dd12v with non-unique default key
      , dd17v_tab type standard table of dd17v with non-unique default key
      , dd35v_tab type standard table of dd35v with non-unique default key
      , dd36m_tab type standard table of dd36m with non-unique default key
      , end of ty_s__tabl .

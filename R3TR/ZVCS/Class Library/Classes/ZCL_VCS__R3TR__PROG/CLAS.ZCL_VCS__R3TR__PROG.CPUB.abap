class ZCL_VCS__R3TR__PROG definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__PROG
*"* do not include other source files here!!!
public section.

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__textpool,
           langu type sy-langu,
           textpool type standard table of textpool
           with non-unique default key,
           end of ty_s__textpool .
  types TY_S__DYNPRO type ZCL_VCS_R3TR___DYNPRO=>TY_S__DYNPRO .
  types TY_T__DYNPRO type ZCL_VCS_R3TR___DYNPRO=>TY_T__DYNPRO .
  types:
    begin of ty_s__prog
    , name      type trdir-name
    , subc      type trdir-subc
    , title     type rglif-title
    , textpool  type ty_s__textpool
    , prog_inf  type rpy_prog
    , source    type zvcst_t__char255
    , dynpros   type ty_t__dynpro
    , end of ty_s__prog .

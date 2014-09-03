class ZCL_VCS__R3TR__MSAG definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__MSAG
*"* do not include other source files here!!!
public section.

  types TY_T__T100 type ZCL_VCS_R3TR___TECH=>TABLES-T100 .
  types:
    begin of ty_s__msag,
            name type arbgb,
            t100 type ty_t__t100,
            end of ty_s__msag .

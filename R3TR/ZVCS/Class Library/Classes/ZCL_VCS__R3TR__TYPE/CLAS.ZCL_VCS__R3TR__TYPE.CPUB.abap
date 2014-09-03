class ZCL_VCS__R3TR__TYPE definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__TYPE
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__type
      , name type trdir-name
      , texts type standard table of ddtypet with non-unique default key
      , source type zvcst_t__char255
      , end of ty_s__type .

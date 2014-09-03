class ZCL_VCS_R3TR___UPLOAD definition
  public
  final
  create public .

*"* public components of class ZCL_VCS_R3TR___UPLOAD
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZVCSC .
  type-pools ZVCST .

  types:
    begin of ty_s__filelist
    , path type string
    , name type string
    , type type string
  , end of ty_s__filelist .
  types:
    ty_t__filelist type sorted table of ty_s__filelist with non-unique key path name .

  methods GET_TYPEOBJ
    returning
      value(E_V__TYPEOBJ) type ZVCST_S__OBJECT .
  class-methods SEARCHFILES
    importing
      !I_V__DIR type STRING default 'C:\TEMP\'
      !I_V__REGEX type STRING default ''
    returning
      value(E_T__FILELIST) type TY_T__FILELIST .
  methods UPLOAD
    exporting
      !E__XMLSOURCE type ANY
      !E_S__HEADER type ANY .
  methods CONSTRUCTOR
    importing
      !I_V__FILENAME type TY_S__FILELIST .

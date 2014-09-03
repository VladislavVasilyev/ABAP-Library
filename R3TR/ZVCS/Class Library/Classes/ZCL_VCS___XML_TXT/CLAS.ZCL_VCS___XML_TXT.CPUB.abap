class ZCL_VCS___XML_TXT definition
  public
  final
  create private .

*"* public components of class ZCL_VCS___XML_TXT
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZVCSC .
  type-pools ZVCST .

  types:
    begin of ty_s__download
              , size type i
              , type type string
              , path type string
              , name type string
              , end of ty_s__download .
  types:
    ty_t__download type standard table of ty_s__download with non-unique default key .

  class-methods DOWNLOAD
    importing
      !I_S__SOURCE type ZVCST_S__DOWNLOAD
    exporting
      !E_T__MESSAGE type TY_T__DOWNLOAD .

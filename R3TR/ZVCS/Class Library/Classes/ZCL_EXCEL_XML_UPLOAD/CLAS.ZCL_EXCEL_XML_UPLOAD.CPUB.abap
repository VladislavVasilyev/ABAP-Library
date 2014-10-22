class ZCL_EXCEL_XML_UPLOAD definition
  public
  inheriting from ZCL_EXCEL_XML
  final
  create public .

*"* public components of class ZCL_EXCEL_XML_UPLOAD
*"* do not include other source files here!!!
public section.
  type-pools ZVCST .

  type-pools ABAP .
  methods UPLOAD_FROM_PC
    importing
      !PATH type STRING
      !FIRST_HEADER type RS_BOOL default ABAP_TRUE .
  methods UPLOAD_FROM_SERV
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID optional
      !I_FILE_NAME type STRING
      !I_FOLDER type STRING
      !I_USER_ID type UJ0_S_USER
      !FIRST_HEADER type RS_BOOL default ABAP_TRUE .
  methods UPLOAD_FROM_SERV_XLSM
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID optional
      !I_FILE_NAME type STRING
      !I_FOLDER type STRING
      !I_USER_ID type UJ0_S_USER
      !FIRST_HEADER type RS_BOOL default ABAP_TRUE .

class ZCL_EXCEL_XML_DOWNLOAD definition
  public
  inheriting from ZCL_EXCEL_XML
  final
  create public .

*"* public components of class ZCL_EXCEL_XML_DOWNLOAD
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .
  methods DOWNLOAD_ON_BPC
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !I_FILE_NAME type STRING
      !I_FOLDER type STRING
      !I_USER_ID type UJ0_S_USER .
  methods DOWNLOAD_ON_PC
    importing
      !PATH type STRING .
  methods DOWNLOAD_ON_SERV
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !I_FILE_NAME type STRING
      !I_FOLDER type STRING
      !I_USER_ID type UJ0_S_USER .
  methods CREATE_XML_WORKBOOK
    importing
      !I_T__WORKSHEET type ZVCST_T__XMLWORKSHEET .

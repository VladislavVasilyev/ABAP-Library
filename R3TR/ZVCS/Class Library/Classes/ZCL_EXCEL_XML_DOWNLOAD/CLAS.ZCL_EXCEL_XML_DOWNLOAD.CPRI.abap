*"* private components of class ZCL_EXCEL_XML_DOWNLOAD
*"* do not include other source files here!!!
private section.

  methods CREATE_STYLES .
  methods CREATE_WORKSHEET
    importing
      !I_S__WORKSHEET type ZVCST_S__XMLWORKSHEET .

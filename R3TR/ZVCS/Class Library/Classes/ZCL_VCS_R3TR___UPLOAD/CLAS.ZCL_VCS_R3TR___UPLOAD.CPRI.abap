*"* private components of class ZCL_VCS_R3TR___UPLOAD
*"* do not include other source files here!!!
private section.

  data GR_O__XMLDOC type ref to CL_XML_DOCUMENT .
  data GD_V__FILENAME type TY_S__FILELIST .
  data GD_V__OBJECT type ZVCST_S__OBJECT .

  methods ADD_TXTSOURCE .
  class-methods SEARCH
    importing
      !I_V__DIR type STRING
      !I_V__REGEX type STRING default ''
    exporting
      !E_T__FILELIST type TY_T__FILELIST .
  methods XMLSEARCHOBJECT
    importing
      !I_I__IXML_NODE type ref to IF_IXML_NODE
    returning
      value(E_V__OBJECT) type ZVCST_S__OBJECT .

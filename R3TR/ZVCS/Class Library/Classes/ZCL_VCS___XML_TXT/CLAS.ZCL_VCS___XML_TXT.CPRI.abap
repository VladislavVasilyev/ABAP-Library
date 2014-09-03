*"* private components of class ZCL_VCS___XML_TXT
*"* do not include other source files here!!!
private section.

  data GD_T__MESSAGE type TY_T__DOWNLOAD .
  data GR_O__XMLDOC type ref to CL_XML_DOCUMENT .
  data GD_V__XMLPATH type STRING .
  data:
    gd_t__xmlformatdoc type standard table of string .
  data GD_S__SOURCE type ZVCST_S__DOWNLOAD .
  data GD_V__PATH type STRING .
  data GD_V__FILENAME type STRING .
  data:
    gd_t__sourcenodepath type range of string .
  data:
    gd_t__sourcenodename type range of string .
  data GD_V__MASTERNAME type STRING .
  data GD_V__XMLNAME type STRING .
  data GD_V__EXTSRCNAME type STRING .
  data GD_T__TXTSOURCE type ZVCST_T__FILE_SOURCE .

  methods WRITE_TO_TXTFILE .
  methods XML2TXT
    importing
      !I_I__IXML_NODE type ref to IF_IXML_NODE
    returning
      value(E_T__TXTSOURCE) type ZVCST_T__SOURCE .
  methods CONSTRUCTOR
    importing
      !I_S__SOURCE type ZVCST_S__DOWNLOAD .
  methods WRITE_TO_XMLFILE .
  methods TAB2XML .
  methods XML2FXML
    importing
      !I_V__TABULATION type I default 0
      !I_I__IXML_NODE type ref to IF_IXML_NODE optional
    returning
      value(E_V__TEXT) type STRING .

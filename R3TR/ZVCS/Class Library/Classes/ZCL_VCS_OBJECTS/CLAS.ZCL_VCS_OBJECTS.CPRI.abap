*"* private components of class ZCL_VCS_OBJECTS
*"* do not include other source files here!!!
private section.

  class-data CD_T__REESTR type TY_T__REESTR .
  class-data CD_V__PATH type ZVCST_S__PATH .
  class-data CD_T__ERROR_STACK type TY_T__ERROR_STACK .
  class-data CD_T__MESSAGE_DOWNLOAD type ZCL_VCS___XML_TXT=>TY_T__DOWNLOAD .
  class-data CD_T__MESSAGE_CREATE type TY_T__CREATE .

  class-methods WRITE_MSG_READ .
  class-methods WRITE_MSG_CREATE .
  class-methods WRITE_MSG_ERROR .
  class-methods GET_PATHDEVC
    importing
      !DEVCLASS type DEVCLASS
    returning
      value(PATHDEVC) type STRING .
  class-methods GET_TABCLASS
    importing
      !OBJ_NAME type CLIKE
    returning
      value(TABCLASS) type TABCLASS .
  class-methods CROSSSOURCES .
  class-methods GET_CROSSSOURCES
    importing
      !I_S__TADIR type ZVCST_S__TADIR
    exporting
      !E_T__TADIR type ZVCST_T__TADIR
    changing
      !C_T__TADIR type ZVCST_T__TADIR optional .
  class-methods PATHS .
  class-methods UPLOAD
    importing
      !I_V__DIRECTORY type STRING .
  class-methods DOWNLOAD .
  class-methods CREATE .
  type-pools ABAP .
  class-methods CHOOSE
    importing
      !I_V__FORM_NAME type FORM_NAME
      !I_F__UPLOAD type RS_BOOL default ABAP_FALSE .
  class-methods READ_OBJECTS .
  class-methods READ .
  class-methods OBJECTS_PATH .
  class-methods DOWNLOAD_OBJECTS .

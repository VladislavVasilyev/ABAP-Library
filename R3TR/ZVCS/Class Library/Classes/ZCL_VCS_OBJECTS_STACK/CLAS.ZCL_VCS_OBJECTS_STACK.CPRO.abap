*"* protected components of class ZCL_VCS_OBJECTS_STACK
*"* do not include other source files here!!!
protected section.

  methods CREATE_PATH
  abstract
    importing
      !I_S__PATH type ZVCST_S__PATH
      !I_S__DIR type ANY
    exporting
      !E_V__PATH type STRING
      !E_V__XMLNAME type STRING
      !E_V__MASTERNAME type STRING
      !E_V__EXTSRCNAME type STRING .
  methods GET_HANDLE
  final
    returning
      value(HANDLE) type ref to CL_ABAP_DATADESCR .
  methods GET_TYPE
  final
    returning
      value(TYPE) type STRING .
  methods CREATE_OBJECT
  abstract
    importing
      !I_R__SOURCE type ANY
      !I_S__TADIR type ZVCST_S__TADIR
    raising
      ZCX_VCS_OBJECTS_CREATE .
  methods CROSSSOURCES
  abstract
    importing
      !I_S__TADIR type ZVCST_S__TADIR
    exporting
      !E_T__TADIR type ZVCST_T__TADIR .
  methods GET_TYPE_OBJECT
  abstract
    exporting
      !TYPE type ZVCST_S__OBJECT
      !TYSOURCE type STRING .
  methods READ_OBJECT
  abstract
    importing
      !I_S__TADIR type ZVCST_S__TADIR
    exporting
      !E_T__TXTSOURCE type ZVCST_T__SOURCE_PATH
      !E_S__SOURCE type ANY
    raising
      ZCX_VCS_OBJECTS_READ .

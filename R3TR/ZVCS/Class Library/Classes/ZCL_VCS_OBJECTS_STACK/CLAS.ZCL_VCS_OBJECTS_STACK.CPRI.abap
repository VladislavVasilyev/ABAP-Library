*"* private components of class ZCL_VCS_OBJECTS_STACK
*"* do not include other source files here!!!
private section.

  class-data CD_T__TASK_STACK type ZVCST_T__TADIR .
  class-data CD_T__STACK type ZVCST_T__OBJECTS_STACK .
  data GD_V__TYOBJECT type STRING .
  data GR_O__SOURCEHANDLE type ref to CL_ABAP_DATADESCR .
  class-data CD_T__OBJECTS_FOR_DOWNLOAD type ZVCST_T__DOWNLOAD .
  class-data CD_T__OBJECTS_FOR_UPLOAD type ZVCST_T__UPLOAD .

  class-methods GET_OBJECT
    importing
      !TYPE type ZVCST_S__OBJECT
    returning
      value(REF) type ref to ZCL_VCS_OBJECTS_STACK .

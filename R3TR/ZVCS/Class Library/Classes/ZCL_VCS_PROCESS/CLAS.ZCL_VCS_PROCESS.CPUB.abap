class ZCL_VCS_PROCESS definition
  public
  create public .

*"* public components of class ZCL_VCS_PROCESS
*"* do not include other source files here!!!
public section.
  type-pools ZVCST .

  class-methods MASTER_DOWNLOAD
    importing
      !I_V__FORM_NAME type FORM_NAME default 'DOWNLOAD' .
  class-methods MASTER_UPLOAD
    importing
      !I_V__DIRECTORY type STRING
      !I_V__FORM_NAME type FORM_NAME .
  methods WRITE_MESSAGE .

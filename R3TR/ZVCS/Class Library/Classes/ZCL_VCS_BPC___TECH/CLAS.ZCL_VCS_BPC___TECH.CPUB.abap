class ZCL_VCS_BPC___TECH definition
  public
  final
  create public .

*"* public components of class ZCL_VCS_BPC___TECH
*"* do not include other source files here!!!
public section.
  type-pools SEOC .
  type-pools SEOK .
  type-pools SEOO .
  type-pools SEOR .
  type-pools SEOS .
  type-pools SEOT .
  type-pools ZVCSC .
  type-pools ZVCST .

  class-methods ZFM_GET_BPC_LGF
    importing
      !I_APPSET type UJ_APPSET_ID
      !I_APPLICATION type UJ_APPL_ID
      !I_FILENAME type UJ_DOCNAME
    exporting
      !E_DOC type UJF_DOC
      !ET_LGF type ZVCST_T__LGFSOURCE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

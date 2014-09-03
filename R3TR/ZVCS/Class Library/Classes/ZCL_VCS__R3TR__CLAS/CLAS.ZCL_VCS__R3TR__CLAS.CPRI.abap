*"* private components of class ZCL_VCS_R3TR__CLAS
*"* do not include other source files here!!!
private section.

  methods READ_REDEF_METHODS
    importing
      !I_T__METHODS type TY_T__METHOD
      !I_T__REDEFINITIONS type SEOR_REDEFINITIONS_R
      !I_T__EXPLORE_INHERITANCE type TY_T__VSEOCLASS
      !I_S__CLSKEY type SEOCLSKEY
    exporting
      !E_T__METHODS_REDEF type TY_T__REDEFINITION
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_LOCALS
    importing
      !I_S__CLSKEY type SEOCLSKEY
    exporting
      !E_T__LOCALS type TY_T__LOCAL
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_METHOD_DETAIL
    importing
      !METHOD type SEOO_METHOD_R
    changing
      !METHOD_DETAILS type SEOO_METHOD_DETAILS
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_METHOD_EXCEPTIONS
    importing
      !METHOD type TY_S__METHOD
    changing
      !METHOD_EXCEPTIONS type SEOS_EXCEPTIONS_R
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_METHOD_PARAMS
    importing
      !METHOD type SEOO_METHOD_R
    exporting
      !PARAMETERS type SEOS_PARAMETERS_R
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_IMPL_METHOD
    importing
      !I_T__METHODS type TY_T__METHOD
      !I_T__ALIASES type SEO_ALIASES
      !I_S__CLSKEY type SEOCLSKEY
    exporting
      !E_T__IMPL_METHODS type TY_T__IMPLMETHOD
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_METHODS
    importing
      !I_T__METHODS type SEOO_METHODS_R
    exporting
      !E_T__METHODS type TY_T__METHOD
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_METHOD_SOURCE
    importing
      !METHOD type SEOO_METHOD_R
    exporting
      !SOURCE type ZVCST_T__CHAR255
    changing
      !INCNAME type PROGRAM
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_SECTIONS
    importing
      !I_S__CLSKEY type SEOCLSKEY
    exporting
      !E_T__SECTION type TY_T__SECTION
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods READ_TYPE_SOURCE
    importing
      !I_T__TYPES type SEOO_TYPES_R
    exporting
      !E_T__SOURCE type ZVCST_T__CHAR255
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

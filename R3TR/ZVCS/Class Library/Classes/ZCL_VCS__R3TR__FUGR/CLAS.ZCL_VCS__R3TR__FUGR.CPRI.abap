*"* private components of class ZCL_VCS__R3TR__FUGR
*"* do not include other source files here!!!
private section.

  methods COLLECT_DYNPRO
    importing
      !AREA type ENLFDIR-AREA
    exporting
      !E_T__DYNPRO type TY_T__DYNPRO
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods COLLECT_FMODULES
    importing
      !AREA type ENLFDIR-AREA
    exporting
      !E_T__FMODULE type TY_T__FMODULE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  methods COLLECT_FUNCAREA
    importing
      !AREA type ENLFDIR-AREA
    exporting
      !E_T__INCLUDES type TY_T__INCLUDE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

*"* private components of class ZCL_VCS__R3TR__PROG
*"* do not include other source files here!!!
private section.

  methods COLLECT_DYNPRO
    importing
      !PROGNAME type TRDIR-NAME
    exporting
      !E_T__DYNPRO type TY_T__DYNPRO
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  type-pools ZVCST .
  methods CREATE_PROGRAM
    importing
      !I_S__PROG type TY_S__PROG
      !I_S__TADIR type ZVCST_S__TADIR
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

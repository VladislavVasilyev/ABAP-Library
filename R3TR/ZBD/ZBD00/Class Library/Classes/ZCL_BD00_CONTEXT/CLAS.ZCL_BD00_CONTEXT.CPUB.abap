class ZCL_BD00_CONTEXT definition
  public
  final
  create private .

*"* public components of class ZCL_BD00_CONTEXT
*"* do not include other source files here!!!
public section.

  class-data GV_APPL_ID type UJ_APPL_ID read-only .
  class-data GV_APPSET_ID type UJ_APPSET_ID read-only .

  class-methods SET_CONTEXT
    importing
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional .

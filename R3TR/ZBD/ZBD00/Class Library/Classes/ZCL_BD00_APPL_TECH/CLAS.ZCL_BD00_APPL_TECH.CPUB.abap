class ZCL_BD00_APPL_TECH definition
  public
  final
  create public .

*"* public components of class ZCL_BD00_APPL_TECH
*"* do not include other source files here!!!
public section.

  methods CREATE_DBSTAT
    importing
      !PERC_NUM type I
    raising
      ZCX_BD00_APPL_TECH .
  methods DROP_INDEX
    raising
      ZCX_BD00_APPL_TECH .
  methods INDEX
    raising
      ZCX_BD00_APPL_TECH .
  methods SWITCH_LOADED
    raising
      ZCX_BD00_APPL_TECH .
  methods SWITCH_PLANNED
    raising
      ZCX_BD00_APPL_TECH .
  methods CONSTRUCTOR
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
    raising
      ZCX_BD00_STATIC_EXCEPTION .

class ZCL_BDNL_WHERE_FUNCTIONS definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_WHERE_FUNCTIONS
*"* do not include other source files here!!!
public section.

  class-data APPSET_ID type UJ_APPSET_ID .
  class-data APPL_ID type UJ_APPL_ID .
  class-data DIMENSION type UJ_DIM_NAME .
  class-data ATTRIBUTE type UJ_ATTR_NAME .

  type-pools ZBNLT .
  class-methods BAS
    importing
      !I01 type ANY
      !I02 type ANY optional
      !I03 type ANY optional
    exporting
      !E type ZBNLT_T__PARAM .
  class-methods GET_ATTR
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY optional
    exporting
      !E type ZBNLT_T__PARAM .
  class-methods CHANGE_YEAR
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ZBNLT_T__PARAM .

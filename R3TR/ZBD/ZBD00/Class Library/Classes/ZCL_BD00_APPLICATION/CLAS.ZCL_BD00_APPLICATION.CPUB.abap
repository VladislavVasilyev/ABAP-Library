class ZCL_BD00_APPLICATION definition
  public
  final
  create private .

*"* public components of class ZCL_BD00_APPLICATION
*"* do not include other source files here!!!
public section.
  type-pools RSD .
  type-pools UJ00 .

  data GD_V__APPSET_ID type UJ_APPSET_ID read-only .
  data GD_S__APPL_INFO type UJA_S_APPL_INFO read-only .
  data GD_T__DIMENSIONS type ZBD00_T_DIMN read-only .
  constants CS_DM type C value `D`. "#EC NOTEXT
  constants CS_AN type C value `A`. "#EC NOTEXT
  constants CS_KF type C value `K`. "#EC NOTEXT
  data GD_V__APPL_ID type UJ_APPL_ID read-only .
  data GD_V__INFOPROVIDE type RSINFOPROV read-only .
  data GD_V__PACKAGE_SIZE type I read-only .
  data GD_V__DIMENSION type UJ_DIM_NAME read-only .

  methods CHECK_DIMENSION
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(E) type RS_BOOL .
  methods GET_TYPE
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(E_TYPE) type RS_BOOL .
  class-methods GET_APPLICATION
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
    returning
      value(E_OBJ) type ref to ZCL_BD00_APPLICATION
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_CUSTOMIZE_APPLICATION
    importing
      !I_APPSET_ID type UJ_APPSET_ID
    returning
      value(E_OBJ) type ref to ZCL_BD00_APPLICATION
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_DIMENSION
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_DIMENSION type UJ_DIM_NAME
    returning
      value(E_OBJ) type ref to ZCL_BD00_APPLICATION
    raising
      ZCX_BD00_CREATE_OBJ .
  class-methods GET_INFOCUBE
    importing
      !I_INFOCUBE type RSINFOPROV
    returning
      value(E_OBJ) type ref to ZCL_BD00_APPLICATION
    raising
      ZCX_BD00_CREATE_OBJ .

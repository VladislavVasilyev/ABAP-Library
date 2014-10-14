*"* private components of class ZCL_BDNL_CONTAINER
*"* do not include other source files here!!!
private section.

  class-data CD_T__TABLE_FOR type TY_T__REESTR .
  class-data CD_T__TABLE_REESTR type TY_T__REESTR .
  class-data CD_V__CURRENT_SCRIPT type STRING .
  class-data CD_V__N_TURN type I .
  class-data CD_V__N_FOR type I .
  class-data CD_V__N_SCRIPT type I .
  class-data CR_S__LOG type ref to TY_S__LOG .
  data GD_S__PARAM type ZBNLT_S__STACK_CONTAINER .
  data GD_V__PACKAGESIZE type I .
  data GD_V__SCRIPT type STRING .
  data GD_V__TURN type I .

  methods CREATE__BPCGEN
    importing
      !I_V__PACKAGE_SIZE type I
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE__BPCDIM
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE__BPC
    importing
      !I_V__PACKAGE_SIZE type I
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE__BP
    importing
      !I_V__PACKAGE_SIZE type I
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE_TABLEFORDOWN
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE_CTABLE
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE_CLEAR
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE_SELECT
    importing
      !I_V__PACKAGE_SIZE type I
    returning
      value(E_F__CREATE) type RS_BOOL .
  methods CREATE_TABLE
    importing
      !F_MASTER type RS_BOOL
      !PACKAGE_SIZE type I .
  methods CONSTRUCTOR
    importing
      !I_PARAM type ZBNLT_S__STACK_CONTAINER .

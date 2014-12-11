class ZCL_BD00_INT_TABLE_CTRL definition
  public
  inheriting from ZCL_BD00_INT_TABLE
  final
  create public .

*"* public components of class ZCL_BD00_INT_TABLE_CTRL
*"* do not include other source files here!!!
public section.

  constants CS_DATA_NAME type STRING value `%var_name%`. "#EC NOTEXT
  constants CS_TYPE_NAME type STRING value `%type_name%`. "#EC NOTEXT
  constants CS_DATA_TYPE type STRING value `data %var_name% type %type name%.`. "#EC NOTEXT
  constants CS_DATA_TYPE_REF_TO type STRING value `data %var_name% type ref to %type name%.`. "#EC NOTEXT
  constants CS_TYPE_TYPE type STRING value `type %var_name% type ref to %type name%.`. "#EC NOTEXT
  constants CS_TY_STRUCT type TY_S_NAME value `ty_line`. "#EC NOTEXT
  constants CS_TY_STRUCT_REL type TY_S_NAME value `ty_fline`. "#EC NOTEXT
  constants CS_TY_TABLE type TY_S_NAME value `ty_table`. "#EC NOTEXT

  type-pools ZBD0T .
  type-pools ABAP .
  class-methods CREATE_DYN_RULE
    importing
      !ID type ZBD0T_ID_RULES
      !I_F__36 type RS_BOOL default ABAP_FALSE
    exporting
      value(CLASS) type STRING
      !ET_OBJECT_REESTR type TY_T_OBJECT_REESTR
    raising
      ZCX_BD00_CREATE_RULE .
  class-methods CREATE_DYN_ADD
    importing
      !IO_TG type ref to ZCL_BD00_APPL_CTRL
      !IO_LINE type ref to ZCL_BD00_APPL_CTRL
    returning
      value(CLASS) type STRING
    raising
      ZCX_BD00_CREATE_RULE .
  class ZCL_BD00_APPL_CTRL definition load .
  methods CONSTRUCTOR
    importing
      !IT_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR .
  class-methods CREATE_DYN_READ
    importing
      !ID type ZBD0T_ID_RULES
      !I_F__36 type RS_BOOL default ABAP_FALSE
    exporting
      !CLASS type STRING
      !ET_OBJECT_REESTR type TY_T_OBJECT_REESTR
    raising
      ZCX_BD00_CREATE_RULE .

  methods ZIF_BD00_INT_TABLE~ADD
    redefinition .
  methods ZIF_BD00_INT_TABLE~NEXT
    redefinition .
  methods ZIF_BD00_INT_TABLE~RULE
    redefinition .

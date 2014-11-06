class ZCL_BD00_INT_TABLE definition
  public
  abstract
  create public

  global friends ZCL_BD00_APPL_CTRL .

*"* public components of class ZCL_BD00_INT_TABLE
*"* do not include other source files here!!!
public section.
  type-pools ZBD0C .
  type-pools ZBD0T .

  interfaces ZIF_BD00_INT_TABLE
      all methods abstract .

  aliases ADD
    for ZIF_BD00_INT_TABLE~ADD .
  aliases NEXT
    for ZIF_BD00_INT_TABLE~NEXT .
  aliases RULE
    for ZIF_BD00_INT_TABLE~RULE .

  types:
    ty_t_string type standard table of string with non-unique default key .
  types TY_S_NAME type STRING .
  types:
    var_index type c length 2 .
  types:
    ty_id_code type c length 2 .
  types:
    begin of ty_s_definition
       , id type ty_id_code
       , name type string
       , code type ty_t_string
       , end of ty_s_definition .
  types:
    ty_t_definition type hashed table of ty_s_definition with unique key id .
  types:
    begin of ty_s_object_reestr
        , id     type i
        , object type ref to zcl_bd00_appl_ctrl
        , data   type ref to data
        , name   type string
        , definition type TY_T_definition
        , end of ty_s_object_reestr .
  types:
    ty_t_object_reestr type sorted table of ty_s_object_reestr with unique key id name object data .

  constants:
    begin of id_code.
    constants type                type ty_id_code value `00`.
    constants type_tab            type ty_id_code value `01`.
    constants data_st             type ty_id_code value `02`.
    constants data_tab            type ty_id_code value `03`.
    constants ref_st              type ty_id_code value `04`.
    constants ref_tab             type ty_id_code value `05`.
    constants field_st            type ty_id_code value `06`.
    constants field_tab           type ty_id_code value `07`.
    constants assign_st           type ty_id_code value `09`.
    constants assign_tab          type ty_id_code value `10`.
    constants global_reference    type ty_id_code value `11`.
    constants assign_cst          type ty_id_code value `12`.
    constants field_cst           type ty_id_code value `13`.
    constants ref_line            type ty_id_code value `14`.
    constants end   of id_code .
  constants:
    begin of method.
    constants add    type zbd0t_ty_method value `ADD`.      "#EC NOTEXT .
    constants assign type zbd0t_ty_method value `RULE`.     "#EC NOTEXT .
    constants search type zbd0t_ty_method value `NEXT`.     "#EC NOTEXT .
    constants end of method .

  class ZCL_BD00_APPL_CTRL definition load .
  methods CONSTRUCTOR
    importing
      !IT_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR .
  class-methods CREATE_RULE
    importing
      !ID type ZBD0T_ID_RULES
    returning
      value(EO_CLASS) type ref to ZCL_BD00_INT_TABLE
    raising
      ZCX_BD00_CREATE_RULE .
  class-methods CREATE_ADD
    importing
      !IO_TG type ref to ZCL_BD00_APPL_CTRL
      !IO_LINE type ref to ZCL_BD00_APPL_CTRL optional
    returning
      value(EO_CLASS) type ref to ZIF_BD00_INT_TABLE
    raising
      ZCX_BD00_CREATE_RULE .
  class-methods CREATE_READ
    importing
      !ID type ZBD0T_ID_RULES
    returning
      value(EO_CLASS) type ref to ZIF_BD00_INT_TABLE
    raising
      ZCX_BD00_CREATE_RULE .

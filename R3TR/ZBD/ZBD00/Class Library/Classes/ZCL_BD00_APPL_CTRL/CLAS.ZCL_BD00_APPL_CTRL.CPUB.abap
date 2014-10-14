class ZCL_BD00_APPL_CTRL definition
  public
  abstract
  create public

  global friends ZCL_BD00_INT_TABLE .

*"* public components of class ZCL_BD00_APPL_CTRL
*"* do not include other source files here!!!
public section.
  type-pools ZBD0T .

  types:
    ty_operation type c length 3 .
  types:
    begin of ty_signature
      , type   type zbd0t_ty_method
      , main   type ref to zcl_bd00_appl_ctrl
      , object type ref to zcl_bd00_appl_ctrl
      , end of ty_signature .
  types:
    begin of ty_s_link
      , tg   type rsalias
      , sc   type rsalias
      , end of ty_s_link .
  types:
    ty_t_link type hashed table of ty_s_link with unique key tg .
  types:
    begin of ty_s_cust_link.
    include type ty_s_link.
    types op     type string.
    types f_key  type rs_bool.
    types object type ref to object.
    types kyf    type uj_dim_name.
    types data   type ref to data.
    types const  type string.
    types end of ty_s_cust_link .
  types:
    ty_t_cust_link type hashed table of ty_s_cust_link with unique key tg op .
  types:
    begin of ty_s_rule_math
      , object type ref to zcl_bd00_appl_ctrl
      , exp type string
      , end of ty_s_rule_math .
  types:
    ty_t_rule_math  type standard table of ty_s_rule_math with non-unique default key .
  types:
    begin of ty_s_rules_reestr
      , id            type zbd0t_id_rules
      , f_delete      type rs_bool
      , type          type zbd0t_ty_method
      , main          type ref to zcl_bd00_appl_ctrl
      , default       type ref to zcl_bd00_appl_ctrl
      , mode_add      type zbd00_mode_add_line
      , f_unique_key  type rs_bool
      , rule_link     type ty_t_cust_link
      , range         type zbd0t_ty_t_range_kf
      , end of ty_s_rules_reestr .
  types:
    ty_t_rules_reestr type hashed table of ty_s_rules_reestr with unique key id .
  types:
    begin of ty_s_const
      , tg  type rsalias
      , const type uj_value
      , end of ty_s_const .
  types:
    ty_t_const type hashed table of ty_s_const with unique key tg .
  types:
    begin of ty_s_class_reg
      , id        type zbd0t_id_rules
      , f_delete  type rs_bool
      , main      type ref to zcl_bd00_appl_ctrl
      , class     type ref to zif_bd00_int_table
      , end of ty_s_class_reg .
  types:
    ty_t_class_reg type hashed table of ty_s_class_reg with unique key id .
  types:
    begin of ty_s_object_reestr
      , object  type ref to zcl_bd00_appl_ctrl
      , f_delete type rs_bool
      , end of ty_s_object_reestr .

  constants CS_ADD type TY_OPERATION value 'ADD'. "#EC NOTEXT
  constants CS_SUB type TY_OPERATION value 'SUB'. "#EC NOTEXT
  class-data GD_T__REESTR_LINK type TY_T_RULES_REESTR read-only .
  constants CS_MUL type TY_OPERATION value 'MUL'. "#EC NOTEXT
  constants CS_DIV type TY_OPERATION value 'DIV'. "#EC NOTEXT
  data GR_O__MODEL type ref to ZCL_BD00_MODEL read-only .

  events EV_DELETE_LINE .
  events EV_CHANGE_LINE .
  events EV_CHANGE_TABLE .

  methods GET_PACKSIZE
    returning
      value(E) type I .
  methods GET_LOG
    exporting
      !E_T__READ type ZBD0T_T__LOG_READ
      !E_T__WRITE type ZBD0T_T__LOG_WRITE
      !E_T__READ_DIM type ZBD0T_T__LOG_DIMENSION
      !E_T__ACTUAL_ROWS type ZBD0T_T__LOG_ACTUAL .
  class-methods GET_RULE_CLASS
    importing
      !ID type ZBD0T_ID_RULES
    returning
      value(CLASS) type ref to ZIF_BD00_INT_TABLE .
  methods FREE_OBJECT .
  class-methods FREE_ALL_OBJECT .
  methods CLEAR .
  methods RULE_ASSIGN_1
    importing
      !CLASS type ref to ZIF_BD00_INT_TABLE .
  methods RULE_ASSIGN
    importing
      !ID type ZBD0T_ID_RULES .
  methods MATH
    importing
      !OPERAND type ref to ZCL_BD00_APPL_CTRL optional
      !OPERATION type TY_OPERATION
      !SIGNEDDATA type UJ_KEYFIGURE optional .
  methods SET_RULE_ASSIGN
    importing
      !IT_FIELD type ZBD0T_TY_T_CUSTOM_LINK optional
      !IS_MATH type ZBD0T_TY_S_RULE_MATH optional
      !IO_DEFAULT type ref to ZCL_BD00_APPL_CTRL optional
      !I_MODE_ADD type ZBD00_MODE_ADD_LINE optional
      !IT_LINK type ZBD0T_TY_T_LINK_KEY optional
    returning
      value(E_ID) type ZBD0T_ID_RULES .
  methods SET_CH
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
      !VALUE type UJ_VALUE .
  methods GET_REF
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(REF) type ref to DATA .
  methods GET_CH
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    returning
      value(FIELD) type UJ_VALUE .
  methods GET_ANY
    importing
      !DIMENSION type UJ_DIM_NAME
      !ATTRIBUTE type UJ_ATTR_NAME optional
    exporting
      !FIELD type ANY .
  methods GET_KF
    returning
      value(KF) type UJ_KEYFIGURE .

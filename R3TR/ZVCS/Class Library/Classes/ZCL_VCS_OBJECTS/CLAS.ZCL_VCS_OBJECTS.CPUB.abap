class ZCL_VCS_OBJECTS definition
  public
  abstract
  final
  create public

  global friends ZCL_VCS_PROCESS .

*"* public components of class ZCL_VCS_OBJECTS
*"* do not include other source files here!!!
public section.
  type-pools ZVCSC .
  type-pools ZVCST .

  types:
    begin of ty_s__reestr
        , system type pgmid
        , object type ref to zcl_vcs_objects
        , end of ty_s__reestr .
  types:
    ty_t__reestr type standard table of ty_s__reestr .
  types:
    begin of ty_s__vcs_object
        , type   type trobjtype
        , object type ref to zcl_vcs_objects_stack
        , source type ref to cl_abap_datadescr
        , error  type rs_bool
        , end of ty_s__vcs_object .
  types:
    ty_t__vcs_object type hashed table of ty_s__vcs_object with unique key type .
  types:
    begin of ty_s__error_stack
        , cx_ref type ref to zcx_vcs_objects
        , end of ty_s__error_stack .
  types:
    ty_t__error_stack type standard table of ty_s__error_stack with non-unique default key .
  types:
    begin of ty_s__create
         , pgmid type string
         , type type string
         , name type string
         , end of ty_s__create .
  types:
    ty_t__create type standard table of ty_s__create with non-unique default key .

  class-data CD_F__POPUP type RS_BOOL .

  class-methods CLASS_CONSTRUCTOR .
  class-methods SET_TASK_DOWNLOAD_FOR_BPC
    importing
      !I_T__APPSET_ID type ZVCST_T__APPSET
      !I_T__APPL_ID type ZVCST_T__APPLICATION
      !I_S__PATH type ZVCST_S__PATH
      !I_F__LGF type RS_BOOL
      !I_F__PACK type RS_BOOL
      !I_F__XLTP type RS_BOOL .
  class-methods SET_TASK_DOWNLOAD_FOR_R3TR
    importing
      !I_T__OBJECT type ZVCST_T__R3TR_OBJ
      !I_S__PATH type ZVCST_S__PATH .

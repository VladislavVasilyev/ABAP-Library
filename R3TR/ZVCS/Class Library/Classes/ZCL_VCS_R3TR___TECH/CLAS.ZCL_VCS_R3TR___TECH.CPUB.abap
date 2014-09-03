class ZCL_VCS_R3TR___TECH definition
  public
  final
  create public .

*"* public components of class ZCL_VCS_R3TR___TECH
*"* do not include other source files here!!!
public section.
  type-pools SEOC .
  type-pools SEOK .
  type-pools SEOO .
  type-pools SEOR .
  type-pools SEOS .
  type-pools SEOT .
  type-pools ZVCSC .
  type-pools ZVCST .

  types:
    begin of ty_s_t100,
           sprsl type t100-sprsl,
           msgnr type t100-msgnr,
           text type t100-text,
           end of ty_s_t100 .
  types:
    begin of tables
*               , dd07v type standard table of dd07v with non-unique default key
*               , dd03p type standard table of dd03p with non-unique default key
*               , dd05m type standard table of dd05m with non-unique default key
               , dd08v type standard table of dd08v with non-unique default key
               , dd12v type standard table of dd12v with non-unique default key
               , dd17v type standard table of dd17v with non-unique default key
               , dd35v type standard table of dd35v with non-unique default key
               , dd36m type standard table of dd36m with non-unique default key
               , dd26v type standard table of dd26v with non-unique default key
               , dd27p type standard table of dd27p with non-unique default key
               , dd28j type standard table of dd28j with non-unique default key
               , dd28v type standard table of dd28v with non-unique default key
               , dd42v type standard table of dd42v with non-unique default key
               , dd31v type standard table of dd31v with non-unique default key
               , dd32p type standard table of dd32p with non-unique default key
               , dd33v type standard table of dd33v with non-unique default key
               , ddtypet type standard table of ddtypet with non-unique default key
               , rsimp type standard table of rsimp with non-unique default key
               , rscha type standard table of rscha with non-unique default key
               , rsexp type standard table of rsexp with non-unique default key
               , rstbl type standard table of rstbl with non-unique default key
               , rsexc type standard table of rsexc with non-unique default key
               , rsfdo type standard table of rsfdo with non-unique default key
               , include type standard table of include with non-unique default key
               , rpy_dyflow type standard table of rpy_dyflow with non-unique default key
               , rpy_dypara type standard table of rpy_dypara with non-unique default key
               , rpy_repo   type standard table of rpy_repo with non-unique default key
               , abapsource type standard table of abapsource with non-unique default key
               , abaptxt255 type standard table of abaptxt255 with non-unique default key
               , textpool   type standard table of textpool with non-unique default key
               , t100 type sorted table of ty_s_t100 with unique key msgnr sprsl
               , TDEVC type standard table of TDEVC with non-unique default key
               , end of tables .

  class-methods TR_DEVCLASS_GET
    importing
      !IV_DEVCLASS type TDEVC-DEVCLASS
      !IV_LANGU type TDEVCT-SPRAS
    exporting
      !ES_TDEVC type TDEVC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RS_DD_TYGR_INSERT_SOURCES
    importing
      !TYPEGROUPNAME type RSEDD0-TYPEGROUP
      !DDTEXT type DDTYPET-DDTEXT
      !CORRNUM type E070-TRKORR
      !DEVCLASS type TADIR-DEVCLASS
      !SOURCE type ZVCST_T__CHAR255 .
  class-methods RS_CORR_INSERT
    importing
      !OBJECT type CLIKE
      !OBJECT_CLASS type CLIKE
      !MODE type C default SPACE
      !GLOBAL_LOCK type C default SPACE
      !USE_KORRNUM_IMMEDIATEDLY type C default SPACE
      !MASTER_LANGUAGE type SY-LANGU default SPACE
      !GENFLAG type TADIR-GENFLAG default SPACE
      !PROGRAM type SY-REPID default SPACE
      !OBJECT_CLASS_SUPPORTS_MA type C default SPACE
      !EXTEND type C default SPACE
      !SUPPRESS_DIALOG type C default SPACE
      !MOD_LANGU type SY-LANGU default SPACE
      !ACTIVATION_CALL type C default SPACE
      !AUTHOR type SY-UNAME default SPACE
      !DEVCLASS type TADIR-DEVCLASS default SPACE
      !KORRNUM type E070-TRKORR default SPACE
    exporting
      !ORDERNUM type E070-TRKORR
      !NEW_CORR_ENTRY type C
      !TRANSPORT_KEY type TRKEY
      !NEW_EXTEND type C
      !EAUTHOR type SY-UNAME
      !EDEVCLASS type TADIR-DEVCLASS
      !EKORRNUM type E070-TRKORR
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RPY_PROGRAM_INSERT
    importing
      !APPLICATION type RGLIF-APPL default 'X'
      !AUTHORIZATION_GROUP type RGLIF-AUTH default SPACE
      !DEVELOPMENT_CLASS type RGLIF-DEVCLASS default SPACE
      !EDIT_LOCK type RGLIF-EDIT_LOCK default SPACE
      !LOG_DB type RGLIF-LOGDB default SPACE
      !PROGRAM_NAME type RGLIF-INCLUDE
      !PROGRAM_TYPE type RGLIF-PROGTYPE default '1'
      !R2_FLAG type RGLIF-R2 default SPACE
      !TEMPORARY type RGLIF-TEMPORARY default SPACE
      !TITLE_STRING type RGLIF-TITLE
      !TRANSPORT_NUMBER type RGLIF-TRKORR default SPACE
      !SAVE_INACTIVE type PROGDIR-STATE default SPACE
      !SOURCE_EXTENDED type ZVCST_T__CHAR255
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RPY_DYNPRO_INSERT
    importing
      !SUPPRESS_CORR_CHECKS type C default ' '
      !CORRNUM type E071-TRKORR default SPACE
      !SUPPRESS_EXIST_CHECKS type C default ' '
      !SUPPRESS_GENERATE type C default ' '
      !SUPPRESS_DICT_SUPPORT type C default ' '
      !SUPPRESS_EXTENDED_CHECKS type C default ' '
      !HEADER type RPY_DYHEAD
      !USE_CORRNUM_IMMEDIATEDLY type C default ' '
      !SUPPRESS_COMMIT_WORK type C default ' '
      !CONTAINERS type DYCATT_TAB
      !FIELDS_TO_CONTAINERS type DYFATC_TAB
      !FLOW_LOGIC type TABLES-RPY_DYFLOW
      !PARAMS type TABLES-RPY_DYPARA
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods MESSAGE_CLASSES_GET_INFO
    importing
      !I_V__MESSAGECLASSNAME type ARBGB
    exporting
      !E_T__CLASS type TABLES-T100
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RPY_PROGRAM_READ
    importing
      !LANGUAGE type SY-LANGU default SY-LANGU
      !PROGRAM_NAME type RPY_PROG-PROGNAME
      !WITH_INCLUDELIST type RGLIF-WITH_INCL default 'X'
      !ONLY_SOURCE type RGLIF-ONLY_SOURC default ' '
      !ONLY_TEXTS type RGLIF-ONLY_TEXTS default ' '
      !READ_LATEST_VERSION type PROGDIR-STATE default SPACE
      !WITH_LOWERCASE type RGLIF-LOWERCASE default ' '
    exporting
      !PROG_INF type RPY_PROG
      !INCLUDE_TAB type TABLES-RPY_REPO
      !SOURCE type TABLES-ABAPSOURCE
      !SOURCE_EXTENDED type TABLES-ABAPTXT255
      !TEXTELEMENTS type TABLES-TEXTPOOL
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RPY_DYNPRO_READ
    importing
      !PROGNAME type D020S-PROG
      !DYNNR type D020S-DNUM
      !SUPPRESS_EXIST_CHECKS type C default ''
      !SUPPRESS_CORR_CHECKS type C default ''
    exporting
      !HEADER type RPY_DYHEAD
      !CONTAINERS type DYCATT_TAB
      !FIELDS_TO_CONTAINERS type DYFATC_TAB
      !FLOW_LOGIC type TABLES-RPY_DYFLOW
      !PARAMS type TABLES-RPY_DYPARA
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods READ_SOURCE
    importing
      !I_V__NAME type PROGNAME
    exporting
      !E_T__SOURCE type ZVCST_T__CHAR255
      !E_V__LINES_TRUNCATED type I
      !E_F__LONG type SCRPFLAG
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RS_PROGNAME_SPLIT
    importing
      !PROGNAME_WITH_NAMESPACE type RS38L-INCLUDE
    exporting
      !NAMESPACE type RS38L-NAMESPACE
      !PROGNAME_WITHOUT_NAMESPACE type RS38L-INCLUDE
      !FUGR_IS_NAME type C
      !FUGR_IS_RESERVED_NAME type C
      !FUGR_IS_FUNCTIONPOOL_NAME type C
      !FUGR_IS_INCLUDE_NAME type C
      !FUGR_IS_FUNCTIONMODULE_NAME type C
      !FUGR_IS_HIDDEN_NAME type C
      !FUGR_GROUP type RS38L-AREA
      !FUGR_INCLUDE_NUMBER type TFDIR-INCLUDE
      !FUGR_SUFFIX type RS38L-SUFFIX
      !FUGR_IS_RESERVED_EXIT_NAME type C
      !SLDB_IS_RESERVED_NAME type C
      !SLDB_LOGDB_NAME type LDBD-LDBNAME
      !MST_IS_RESERVED_NAME type C
      !TYPE_IS_RESERVED_NAME type C
      !TYPE_NAME type C
      !MENU_IS_RESERVED_NAME type C
      !MENU_NAME type C
      !CLASS_IS_RESERVED_NAME type C
      !CLASS_IS_NAME type C
      !CLASS_NAME type SEOCLSNAME
      !CLASS_IS_METHOD_NAME type C
      !CLASS_METHOD_NAME type SEOCPDNAME
      !CNTX_IS_RESERVED_NAME type C
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RS_GET_ALL_INCLUDES
    importing
      !PROGRAM type SY-REPID
      !WITH_INACTIVE_INCLS type C default ''
      !WITH_RESERVED_INCLUDES type SY-INPUT optional
    exporting
      !INCLUDETAB type TABLES-INCLUDE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods RPY_FUNCTIONMODULE_READ
    importing
      !FUNCTIONNAME type RS38L-NAME
    exporting
      !GLOBAL_FLAG type RS38L-GLOBAL
      !REMOTE_CALL type RS38L-REMOTE
      !UPDATE_TASK type RS38L-UTASK
      !SHORT_TEXT type TFTIT-STEXT
      !FUNCTION_POOL type RS38L-AREA
      !IMPORT_PARAMETER type TABLES-RSIMP
      !CHANGING_PARAMETER type TABLES-RSCHA
      !EXPORT_PARAMETER type TABLES-RSEXP
      !TABLES_PARAMETER type TABLES-RSTBL
      !EXCEPTION_LIST type TABLES-RSEXC
      !DOCUMENTATION type TABLES-RSFDO
      !SOURCE type ZVCST_T__CHAR255
      !AREA type ENLFDIR-AREA
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SECTION_GET_SOURCE
    importing
      !CIFKEY type SEOCLSKEY
      !LIMU type TROBJTYPE
      value(STATE) type R3STATE optional
    exporting
      !INCNAME type PROGRAM
      !SOURCE type SEO_SECTION_SOURCE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods PRETTY_PRINTER
    importing
      value(INCTOO) type C default SPACE
    exporting
      value(INDENTATION_MAYBE_WRONG) type C
    changing
      !NTEXT type ZVCST_T__CHAR255
      !OTEXT type ZVCST_T__CHAR255
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  type-pools SEOX .
  class-methods PARAMETER_READ_ALL
    importing
      !CMPKEY type SEOCMPKEY
      !MASTER_LANGUAGE type MASTERLANG default SY-LANGU
      !MODIF_LANGUAGE type MASTERLANG default SY-LANGU
      !VERSION type SEOVERSION default SEOC_VERSION_INACTIVE
      !WITH_DESCRIPTIONS type SEOX_BOOLEAN default SEOX_TRUE
    exporting
      !PARAMETERS type SEOS_PARAMETERS_R
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

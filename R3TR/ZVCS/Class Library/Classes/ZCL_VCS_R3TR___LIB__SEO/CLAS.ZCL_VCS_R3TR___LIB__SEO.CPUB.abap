class ZCL_VCS_R3TR___LIB__SEO definition
  public
  final
  create public .

*"* public components of class ZCL_VCS_R3TR___LIB__SEO
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
    begin of tb
    , seoclasstx type standard table of seoclasstx with non-unique default key
    , seocompotx type standard table of seocompotx with non-unique default key
    , seosubcotx type standard table of seosubcotx with non-unique default key
    , t100 type sorted table of ty_s_t100 with unique key msgnr
    , end of tb .

  type-pools SEOX .
  class-methods SEO_INTERFACE_CREATE_COMPLETE
    importing
      !CORRNR type TRKORR optional
      !DEVCLASS type DEVCLASS optional
      !VERSION type SEOVERSION default SEOC_VERSION_INACTIVE
      !GENFLAG type GENFLAG default SPACE
      !AUTHORITY_CHECK type SEOX_BOOLEAN default SEOX_TRUE
      !OVERWRITE type SEOX_BOOLEAN default SEOX_FALSE
      !SUPPRESS_REFACTORING_SUPPORT type SEOX_BOOLEAN default SEOX_TRUE
      !CLASS_DESCRIPTIONS type TB-SEOCLASSTX optional
      !COMPONENT_DESCRIPTIONS type TB-SEOCOMPOTX optional
      !SUBCOMPONENT_DESCRIPTIONS type TB-SEOSUBCOTX optional
    exporting
      !KORRNR type TRKORR
    changing
      !INTERFACE type VSEOINTERF
      !COMPRISINGS type SEOR_COMPRISINGS_R
      !ATTRIBUTES type SEOO_ATTRIBUTES_R
      !METHODS type SEOO_METHODS_R
      !EVENTS type SEOO_EVENTS_R
      !PARAMETERS type SEOS_PARAMETERS_R
      !EXCEPS type SEOS_EXCEPTIONS_R
      !ALIASES type SEOO_ALIASES_R
      !TYPEPUSAGES type SEOT_TYPEPUSAGES_R
      !CLSDEFERRDS type SEOT_CLSDEFERRDS_R
      !INTDEFERRDS type SEOT_INTDEFERRDS_R
      !TYPES type SEOO_TYPES_R
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_CLASS_EXISTENCE_CHECK
    importing
      !CLSKEY type SEOCLSKEY
    exporting
      !NOT_ACTIVE type SEOX_BOOLEAN
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_INTERFACE_TYPEINFO_GET
    importing
      !INTKEY type SEOCLSKEY
      !VERSION type SEOVERSION default SEOC_VERSION_INACTIVE
      !STATE type SEOSTATE default '1'
      !WITH_MASTER_LANGUAGE type SEOX_BOOLEAN default SEOX_FALSE
      !WITH_ENHANCEMENTS type SEOX_BOOLEAN default SEOX_FALSE
      !READ_ACTIVE_ENHA type SEOX_BOOLEAN default SEOX_FALSE
      !ENHA_ACTION type SEOX_BOOLEAN default SEOX_FALSE
      !IGNORE_SWITCHES type CHAR1 default 'X'
    exporting
      !INTERFACE type VSEOINTERF
      !ATTRIBUTES type SEOO_ATTRIBUTES_R
      !METHODS type SEOO_METHODS_R
      !EVENTS type SEOO_EVENTS_R
      !PARAMETERS type SEOS_PARAMETERS_R
      !EXCEPS type SEOS_EXCEPTIONS_R
      !COMPRISINGS type SEOR_COMPRISINGS_R
      !TYPEPUSAGES type SEOT_TYPEPUSAGES_R
      !CLSDEFERRDS type SEOT_CLSDEFERRDS_R
      !INTDEFERRDS type SEOT_INTDEFERRDS_R
      !EXPLORE_COMPRISINGS type SEOK_INT_TYPEINFOS
      !ALIASES type SEOO_ALIASES_R
      !TYPES type SEOO_TYPES_R
      !ENHANCEMENT_METHODS type ENHMETH_TABHEADER
      !ENHANCEMENT_ATTRIBUTES type ENHCLASSTABATTRIB
      !ENHANCEMENT_EVENTS type ENHCLASSTABEVENT
      !ENHANCEMENT_COMPRISINGS type ENHCLASSTABINTFCOMPRI
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_SECTION_GET_SOURCE
    importing
      !CIFKEY type SEOCLSKEY
      !LIMU type TROBJTYPE
      value(STATE) type R3STATE optional
    exporting
      !INCNAME type PROGRAM
      !SOURCE type SEO_SECTION_SOURCE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_PARAMETER_READ_ALL
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
  class-methods SEO_METHOD_GET_DETAIL
    importing
      !CPDKEY type SEOCPDKEY
    exporting
      !METHOD type VSEOMETHOD
      !METHOD_DETAILS type SEOO_METHOD_DETAILS
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_EXCEPTION_READ_ALL
    importing
      !CMPKEY type SEOCMPKEY
      !MASTER_LANGUAGE type MASTERLANG default SY-LANGU
      !MODIF_LANGUAGE type MASTERLANG default SY-LANGU
      !VERSION type SEOVERSION default SEOC_VERSION_INACTIVE
      !WITH_DESCRIPTIONS type SEOX_BOOLEAN default SEOX_TRUE
    exporting
      !EXCEPS type SEOS_EXCEPTIONS_R
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  type-pools SEOF .
  class-methods SEO_CLASS_TYPEINFO_GET
    importing
      !CLSKEY type SEOCLSKEY
      !VERSION type SEOVERSION default SEOC_VERSION_INACTIVE
      !STATE type SEOSTATE default '1'
      !WITH_DESCRIPTIONS type SEOX_BOOLEAN default SEOX_TRUE
      !RESOLVE_EVENTHANDLER_TYPEINFO type SEOX_BOOLEAN default SEOX_FALSE
      !WITH_MASTER_LANGUAGE type SEOX_BOOLEAN default SEOX_FALSE
      !WITH_ENHANCEMENTS type SEOX_BOOLEAN default SEOX_FALSE
      !READ_ACTIVE_ENHA type SEOX_BOOLEAN default SEOX_FALSE
      !ENHA_ACTION type SEOX_BOOLEAN default SEOX_FALSE
      !IGNORE_SWITCHES type CHAR1 default 'X'
    exporting
      !CLASS type VSEOCLASS
      !ATTRIBUTES type SEOO_ATTRIBUTES_R
      !METHODS type SEOO_METHODS_R
      !EVENTS type SEOO_EVENTS_R
      !TYPES type SEOO_TYPES_R
      !PARAMETERS type SEOS_PARAMETERS_R
      !EXCEPS type SEOS_EXCEPTIONS_R
      !IMPLEMENTINGS type SEOR_IMPLEMENTINGS_R
      !INHERITANCE type VSEOEXTEND
      !REDEFINITIONS type SEOR_REDEFINITIONS_R
      !IMPL_DETAILS type SEOR_REDEFINITIONS_R
      !FRIENDSHIPS type SEOF_FRIENDSHIPS_R
      !TYPEPUSAGES type SEOT_TYPEPUSAGES_R
      !CLSDEFERRDS type SEOT_CLSDEFERRDS_R
      !INTDEFERRDS type SEOT_INTDEFERRDS_R
      !EXPLORE_INHERITANCE type SEOK_CLS_TYPEINFOS
      !EXPLORE_IMPLEMENTINGS type SEOK_INT_TYPEINFOS
      !ALIASES type SEOO_ALIASES_R
      !ENHANCEMENT_METHODS type ENHMETH_TABHEADER
      !ENHANCEMENT_ATTRIBUTES type ENHCLASSTABATTRIB
      !ENHANCEMENT_EVENTS type ENHCLASSTABEVENT
      !ENHANCEMENT_IMPLEMENTINGS type ENHCLASSTABIMPLEMENTING
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  type-pools SEOP .
  class-methods SEO_CLASS_GET_METHOD_INCLUDES
    importing
      !CLSKEY type SEOCLSKEY
    exporting
      !INCLUDES type SEOP_METHODS_W_INCLUDE
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_METHOD_GET
    importing
      !MTDKEY type SEOCMPKEY
      !VERSION type SEOVERSION default SEOC_VERSION_INACTIVE
    exporting
      !METHOD type VSEOMETHOD
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_METHOD_GET_SOURCE
    importing
      !MTDKEY type SEOCPDKEY
      !STATE type R3STATE optional
    exporting
      !SOURCE type ZVCST_T__CHAR255
      !INCNAME type PROGRAM
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_CLASS_GET_TYPE_SOURCE
    importing
      !TYPKEY type SEOCMPKEY
    exporting
      !SOURCE type ZVCST_T__CHAR255
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods SEO_CLASS_GET_INCLUDE_SOURCE
    importing
      !CLSKEY type SEOCLSKEY
      value(INCTYPE) type C
    exporting
      !SOURCE type ZVCST_T__CHAR255
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

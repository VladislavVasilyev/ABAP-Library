class ZCL_VCS__R3TR__CLAS definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  create public .

*"* public components of class ZCL_VCS__R3TR__CLAS
*"* do not include other source files here!!!
public section.
  type-pools SEOF .
  type-pools SEOK .
  type-pools SEOO .
  type-pools SEOR .
  type-pools SEOS .
  type-pools SEOT .
  type-pools ZVCST .

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    ty_t__clsname type hashed table of seoclsname with unique default key .
  types TY_S__VSEOCLASS type VSEOCLASS .
  types:
    ty_t__vseoclass type standard table of ty_s__vseoclass with non-unique default key .
  types:
    begin of ty_s__section
    , limu type  trobjtype
    , incname type program
    , source type zvcst_t__char255 "seop_source
    , end of ty_s__section .
  types:
    ty_t__section type standard table of ty_s__section with non-unique default key .
  types:
    begin of ty_s__types
    , types type seoo_types_r
    , type_source type zvcst_t__char255 "seop_source
    , end of ty_s__types .
  types:
    begin of ty_s__method
    , cmpkey type seocmpkey
    , method type line of seoo_methods_r
    , method_details type seoo_method_details
    , parameters type seos_parameters_r
    , exceptions type seos_exceptions_r
    , incname type program
    , source type zvcst_t__char255 "seop_source
    , end of ty_s__method .
  types:
    ty_t__method type standard table of ty_s__method with non-unique default key .
  types:
    begin of ty_s__implementings
    , implementings type  seor_implementings_r
    , impl_details type  seo_redefinitions
    , end of ty_s__implementings .
  types:
    begin of ty_s__implmethod
    , method type  vseomethod
    , alias type line of seo_aliases
    , include type line of seop_methods_w_include
    , source type zvcst_t__char255
    , end of ty_s__implmethod .
  types:
    ty_t__implmethod type standard table of ty_s__implmethod with non-unique default key .
  types:
    begin of ty_s__redefinition
    , method type  vseomethod
    , include type line of seop_methods_w_include
    , source type zvcst_t__char255
    , end of ty_s__redefinition .
  types:
    ty_t__redefinition type standard table of ty_s__redefinition with non-unique default key .
  types:
    begin of ty_s__local
    , name(3)
    , source type zvcst_t__char255
    , end of ty_s__local .
  types:
    ty_t__local type standard table of ty_s__local with non-unique default key .
  types:
    begin of ty_s__ooclass
    , vseoclass           type vseoclass
    , friends             type seof_friendships_r
    , attributes          type seoo_attributes_r
    , methods             type ty_t__method
    , events              type seoo_events_r
    , types               type ty_s__types
    , typepusages         type seot_typepusages_r
    , aliases             type seo_aliases
    , implementings       type ty_s__implementings
    , methods_impl        type ty_t__implmethod
    , inheritance         type seor_inheritance_r
    , explore_inheritance type ty_t__vseoclass
    , redefinitions       type seor_redefinitions_r
    , methods_redef       type ty_t__redefinition
    , classdeferreds      type seot_clsdeferrds_r
    , interfacedeferreds  type seot_intdeferrds_r
    , locals              type ty_t__local
    , sections            type ty_t__section
    , end   of ty_s__ooclass .
  types:
    ty_t__ooclass type hashed table of ty_s__ooclass with unique key vseoclass-clsname .

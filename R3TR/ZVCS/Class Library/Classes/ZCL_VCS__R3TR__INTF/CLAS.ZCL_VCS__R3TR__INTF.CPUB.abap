class ZCL_VCS__R3TR__INTF definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__INTF
*"* do not include other source files here!!!
public section.
  type-pools SEOK .
  type-pools SEOO .
  type-pools SEOR .
  type-pools SEOS .
  type-pools SEOT .

  interfaces ZIF_VCS_R3TR_OBJSERVICE
      all methods final .

  types:
    begin of ty_s__intf
      , intkey              type seoclskey
      , interface           type vseointerf
      , attributes          type seoo_attributes_r
      , methods             type seoo_methods_r
      , events              type seoo_events_r
      , parameters          type seos_parameters_r
      , exceps              type seos_exceptions_r
      , comprisings         type seor_comprisings_r
      , typepusages         type seot_typepusages_r
      , clsdeferrds         type seot_clsdeferrds_r
      , intdeferrds         type seot_intdeferrds_r
      , explore_comprisings type seok_int_typeinfos
      , aliases             type seoo_aliases_r
      , types               type seoo_types_r
      , end of ty_s__intf .

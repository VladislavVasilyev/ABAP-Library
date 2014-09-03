class ZCL_VCS__R3TR__FUGR definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__R3TR__FUGR
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__fmodule,
           funcname type enlfdir-funcname,
           area type enlfdir-area,
           global_flag type  rs38l-global,
           remote_call type rs38l-remote,
           update_task type rs38l-utask,
           short_text  type tftit-stext,
           t_import  type standard table of rsimp
                     with non-unique default key,
           t_change  type standard table of rscha
                     with non-unique default key,
           t_export  type standard table of rsexp
                     with non-unique default key,
           t_tables  type standard table of rstbl
                     with non-unique default key,
           t_except  type standard table of rsexc
                     with non-unique default key,
           source    type zvcst_t__char255,
    end of ty_s__fmodule .
  types:
    ty_t__fmodule type standard table of ty_s__fmodule
           with non-unique default key .
  types:
    begin of ty_s__include,
           include type rseuinc-include,
           source type zvcst_t__char255,
           end of ty_s__include .
  types:
    ty_t__include type standard table of ty_s__include
           with non-unique default key .
  types TY_S__DYNPRO type ZCL_VCS_R3TR___DYNPRO=>TY_S__DYNPRO .
  types TY_T__DYNPRO type ZCL_VCS_R3TR___DYNPRO=>TY_T__DYNPRO .
  types:
    begin of ty_s__fgroup,
           area type enlfdir-area,
           tadir type tadir,
           includes type ty_t__include,
           fmodules type ty_t__fmodule,
           dynpros type ty_t__dynpro,
           end of ty_s__fgroup .

  constants:
    CS_SAPL type c length 4 value `SAPL`. "#EC NOTEXT

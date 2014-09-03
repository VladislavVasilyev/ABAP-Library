class ZCL_VCS_R3TR___DYNPRO definition
  public
  final
  create public .

*"* public components of class ZCL_VCS_R3TR___DYNPRO
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__dynproname,
            progname type d020s-prog,
         dynnr type d020s-dnum,
         end of ty_s__dynproname .
  types:
    ty_t__dynproname type standard table of ty_s__dynproname with non-unique default key .
  types:
    begin of ty_s__dynpro,
            progname type d020s-prog,
            dynnr type d020s-dnum,
            header type rpy_dyhead,
            containers type dycatt_tab,
            fields_to_containers type dyfatc_tab,
            flow_logic type standard table of rpy_dyflow
            with non-unique default key,
            params type standard table of rpy_dypara
            with non-unique default key,
            end of ty_s__dynpro .
  types:
    ty_t__dynpro type standard table of ty_s__dynpro
      with non-unique default key .

  class-methods CREATE
    importing
      !I_S__DYNPRO type TY_S__DYNPRO
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods READ
    importing
      !I_S__DYNPRONAME type TY_S__DYNPRONAME
    exporting
      !E_S__DYNPRO type TY_S__DYNPRO
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

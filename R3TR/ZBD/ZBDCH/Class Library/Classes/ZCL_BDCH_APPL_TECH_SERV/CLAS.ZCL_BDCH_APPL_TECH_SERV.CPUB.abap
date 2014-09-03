class ZCL_BDCH_APPL_TECH_SERV definition
  public
  inheriting from CL_UJD_SIMPLE_ACTOR
  final
  create public .

*"* public components of class ZCL_BDCH_APPL_TECH_SERV
*"* do not include other source files here!!!
public section.
  type-pools RSMPC .

  interfaces IF_RSPC_EXECUTE .
  interfaces IF_RSPC_GET_VARIANT .
  interfaces IF_RSPC_MAINTAIN .
  interfaces IF_RSPC_TRANSPORT .

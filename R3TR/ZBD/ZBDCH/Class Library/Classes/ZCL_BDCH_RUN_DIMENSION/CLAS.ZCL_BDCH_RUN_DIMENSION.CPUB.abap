class ZCL_BDCH_RUN_DIMENSION definition
  public
  final
  create public .

*"* public components of class ZCL_BDCH_RUN_DIMENSION
*"* do not include other source files here!!!
public section.
  type-pools ZVCST .

  constants cs_SAVE    type string value `SAVE`.
  constants cs_PROCESS type string value `PROCESS`.


  interfaces IF_UJD_TASK .

  methods CONSTRUCTOR
    importing
      !IO_CONFIG type ref to CL_UJD_CONFIG
    raising
      CX_UJ_DB_ERROR
      CX_UJD_DATAMGR_ERROR .

*"* private components of class ZCL_BD00_APPL_TECH
*"* do not include other source files here!!!
private section.

  data GR_O__APPLICATION type ref to ZCL_BD00_APPLICATION .

  methods DBSTAT
    importing
      !PERC_NUM type I
    raising
      ZCX_BD00_APPL_TECH .
  methods SWITCH_ICUBE_TRANS_BATCH
    importing
      !I_SWITCH type RS_BOOL .

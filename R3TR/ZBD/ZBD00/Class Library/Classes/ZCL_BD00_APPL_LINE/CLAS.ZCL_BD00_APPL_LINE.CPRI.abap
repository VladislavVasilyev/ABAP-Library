*"* private components of class ZCL_BD00_APPL_LINE
*"* do not include other source files here!!!
private section.

  data GD_V__INDEX type I .
  data F_REF_LINE type RS_BOOL .
  data LINE type ref to DATA .
  data CLINE type ref to DATA .
  data F_APPL_TABLE type RS_BOOL .

  methods SET_APPL_TABLE .

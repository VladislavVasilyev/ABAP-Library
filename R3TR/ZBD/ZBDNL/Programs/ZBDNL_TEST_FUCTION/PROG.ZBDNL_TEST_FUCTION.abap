*&---------------------------------------------------------------------*
*& Report  ZBDNL_TEST_FUCTION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBDNL_TEST_FUCTION.



  DATA
  : LR_O__CLASSDESCR TYPE REF TO CL_ABAP_CLASSDESCR
  , LD_S__METHOD     TYPE ABAP_METHDESCR
  .



  LR_O__CLASSDESCR ?= CL_ABAP_CLASSDESCR=>DESCRIBE_BY_NAME( `ZCL_BDNL_WHERE_FUNCTIONS`  ).

  READ TABLE LR_O__CLASSDESCR->METHODS
       WITH KEY NAME = `CHANGE_YEAR`
                INTO LD_S__METHOD.

  BREAK-POINT.

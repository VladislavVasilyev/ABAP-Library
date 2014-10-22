*---------------------------------------------------------------------*
*       FORM X_REFRESH_TCTRL                                          *
*---------------------------------------------------------------------*
* refresh table control (external call)                               *
*---------------------------------------------------------------------*
* VALUE(XE_NAME)   ---> name of view/table to process                 *
* VALUE(XE_SCREEN) ---> screen to refresh from                        *
*---------------------------------------------------------------------*
FORM X_REFRESH_TCTRL USING VALUE(XRT_NAME) LIKE VIMDESC-VIEWNAME
                           VALUE(XRT_SCREEN) LIKE VIMDESC-LISTE.
  DATA: XRT_CONTROL_NAME(16) TYPE C VALUE 'TCTRL_'.

  XRT_CONTROL_NAME+6 = XRT_NAME.
  REFRESH CONTROL XRT_CONTROL_NAME FROM SCREEN XRT_SCREEN.
ENDFORM.                               "x_refresh_tctrl

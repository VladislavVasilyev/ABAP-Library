*&--------------------------------------------------------------------*
*&      Form  BEFORE_LEAVING_EXT                                      *
*&--------------------------------------------------------------------*
* do all the things necessary before leaving - external call          *
*&--------------------------------------------------------------------*
FORM BEFORE_LEAVING_EXT USING VALUE(VIEWNAME) LIKE VIMDESC-VIEWNAME
                              VALUE(MAINTVIEW) LIKE VIMDESC-MAINTVIEW
                              VALUE(EXIT_FORM) LIKE VIMDESC-FRM_BF_END.
* START OF CHANGE DUTTAN 13.01.2009
* Incresing the length of variable NAME.
*  DATA: NAME(20) TYPE C VALUE 'STATUS_'.
  DATA: NAME(40) TYPE C VALUE 'STATUS_'.
* END OF CHANGE.
  FIELD-SYMBOLS: <BLE_STATUS>.

  ASSIGN <STATUS> TO <BLE_STATUS>.
* NAME+7 = VIEWNAME.
  NAME+7 = MAINTVIEW.                  "Subviews
  ASSIGN (NAME) TO <STATUS>.
  IF VIM_CORR_OBJ_VIEWNAME NE VIEWNAME.
    CLEAR MAINT_MODE.
  ELSE.
    MAINT_MODE = <STATUS>-ST_ACTION.
  ENDIF.
  PERFORM BEFORE_LEAVING_FRAME_FUNCTION USING EXIT_FORM.
  ASSIGN <BLE_STATUS> TO <STATUS>.
ENDFORM.                               "before_leaving_ext

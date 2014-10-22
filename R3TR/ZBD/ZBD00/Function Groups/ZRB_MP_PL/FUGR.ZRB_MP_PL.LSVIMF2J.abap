*---------------------------------------------------------------------*
*       FORM VIM_RESTORE_STATE_INFO                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_RESTORE_STATE_INFO.
  STATUS-DATA = <STATUS>-ST_DATA.
  STATUS-MODE =  <STATUS>-ST_MODE.
  STATUS-DELETE =  <STATUS>-ST_DELETE.
  STATUS-ACTION =  <STATUS>-ST_ACTION.
  TITLE         =  <STATUS>-TITLE.
  MAXLINES      =  <STATUS>-MAXLINES.
  F             =  <STATUS>-CUR_FIELD.
  O             =  <STATUS>-CUR_OFFSET.
  FUNCTION      =  <STATUS>-FCODE.
  L = <STATUS>-CUR_LINE.
ENDFORM.                               "vim_restore_state_info

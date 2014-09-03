METHOD SET_BADI_PARAM.

  IF i_para IS NOT INITIAL.
    ds_badi_param-parameter = i_para.
  ENDIF.

ENDMETHOD.

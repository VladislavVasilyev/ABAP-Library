METHOD SET_BADI_PARAM.

  IF i_para IS NOT INITIAL.
    gd_s__badi_param-parameter = i_para.
  ENDIF.

ENDMETHOD.

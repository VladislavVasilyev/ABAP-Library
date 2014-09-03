method create.

*  if not postfix is initial.
*    concatenate dynpro-progname postfix into dynpro-header-program.
*  endif.

  call method zcl_vcs_r3tr___tech=>rpy_dynpro_insert
    exporting
*       SUPPRESS_CORR_CHECKS           = ' '
*       CORRNUM                        = ' '
*       SUPPRESS_EXIST_CHECKS          = ' '
*       SUPPRESS_GENERATE              = ' '
*       SUPPRESS_DICT_SUPPORT          = ' '
*       SUPPRESS_EXTENDED_CHECKS       = ' '
      header                         = i_s__dynpro-header
      containers                     = i_s__dynpro-containers
      fields_to_containers           = i_s__dynpro-fields_to_containers
      flow_logic                     = i_s__dynpro-flow_logic
      params                         = i_s__dynpro-params.







endmethod.

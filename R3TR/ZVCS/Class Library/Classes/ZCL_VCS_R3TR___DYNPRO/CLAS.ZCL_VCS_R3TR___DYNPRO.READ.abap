method read.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  .

  move i_s__dynproname-progname to e_s__dynpro-progname.
  move i_s__dynproname-dynnr to e_s__dynpro-dynnr.

* Selektieren

  call method zcl_vcs_r3tr___tech=>rpy_dynpro_read
    exporting
      progname                    = e_s__dynpro-progname
      dynnr                       = e_s__dynpro-dynnr
*       SUPPRESS_EXIST_CHECKS       = ' '
*       SUPPRESS_CORR_CHECKS        = ' '
    importing
      header                      = e_s__dynpro-header
      containers                  = e_s__dynpro-containers
      fields_to_containers        = e_s__dynpro-fields_to_containers
      flow_logic                  = e_s__dynpro-flow_logic
      params                      = e_s__dynpro-params.

endmethod.

method read_from.

*  constants
*  : cs_dimension      type string value `^([A-Z0-9\_]+)\>`.

  clear default.

  default = gr_o__cursor->get_token( esc = abap_true chn = abap_true ).

  zcl_bdnl_container=>check_table( default ).

endmethod.

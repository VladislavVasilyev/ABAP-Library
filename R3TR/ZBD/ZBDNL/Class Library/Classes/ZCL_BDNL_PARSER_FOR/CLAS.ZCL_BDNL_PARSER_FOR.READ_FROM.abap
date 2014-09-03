method READ_FROM.

  constants
  : cs_dimension      type string value `^([A-Z0-9\_]+)\>`.

  data
  : ld_s__container   type zbnlt_s__stack_container
  .

  clear default.

  default = gr_o__cursor->get_token( esc = abap_true chn = abap_true ).

  read table gd_t__containers
       with key tablename = default
       into ld_s__container.

  if sy-subrc ne 0.
    raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_table_not_defined
                      token  = default
                      index  = gr_o__cursor->gd_v__cindex .
  endif.

endmethod.

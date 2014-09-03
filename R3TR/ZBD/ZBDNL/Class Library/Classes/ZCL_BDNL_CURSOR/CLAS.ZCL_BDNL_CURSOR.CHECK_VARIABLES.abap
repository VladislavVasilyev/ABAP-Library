method CHECK_VARIABLES.

  field-symbols
  : <ld_s__tokenlist> type zbnlt_s__match_res
  .

  loop at gd_t__tokenlist  assigning <ld_s__tokenlist>
       where f_variable eq abap_true.

    if <ld_s__tokenlist>-value is initial.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_var_declared
                       token  = <ld_s__tokenlist>-token
                       index  = sy-tabix.
    endif.
  endloop.

endmethod.

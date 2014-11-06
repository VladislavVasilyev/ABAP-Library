method get_cbg.

  data
  : ld_v__cnt    type i
  , ld_v__index  type i
  , ld_t__param1 type table of string
  , ld_v__param2 type i
  , ld_v__return type string
  , ld_v__start_index type i
  .

  field-symbols
  : <ld_s__tokenlist> type zbnlt_s__match_res
  , <ld_v__value>     type string
  .

  ld_v__start_index = index.

  loop at  gd_t__tokenlist
       from index
       assigning <ld_s__tokenlist>.

    ld_v__index = sy-tabix.

    add 1 to ld_v__cnt.

    case ld_v__cnt.
      when 1. continue.
      when 2."(
        if <ld_s__tokenlist>-token <> zblnc_keyword-open_parenthesis.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-open_parenthesis
                          index     = ld_v__index .
        endif.
      when 3.                                               " param 1
        if <ld_s__tokenlist>-f_letter   = abap_true or
           <ld_s__tokenlist>-f_variable = abap_true.
          assign <ld_s__tokenlist>-refvalue->* to <ld_v__value>.
          split  <ld_v__value> at zblnc_keyword-comma into table ld_t__param1.
        else.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_uncorrect_param
                          token    = `1`
                          token1    = <ld_s__tokenlist>-token
                          index     = ld_v__index .
        endif.
      when 4." ,
        if <ld_s__tokenlist>-token <> zblnc_keyword-comma.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-comma
                          index     = ld_v__index.
        endif.
      when 5.                                               " param 2
        if <ld_s__tokenlist>-f_num  = abap_true.
          assign <ld_s__tokenlist>-refvalue->* to <ld_v__value>.
          ld_v__param2 = <ld_v__value>.
        else.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_uncorrect_param
                          token    = `2`
                          token1    = <ld_s__tokenlist>-token
                          index     = ld_v__index .
        endif.
      when 6." )
        if <ld_s__tokenlist>-token <> zblnc_keyword-close_parenthesis.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-close_parenthesis
                          index     = ld_v__index .
        endif.
      when 7.
        exit.
    endcase.

    delete gd_t__tokenlist.
  endloop.

  read table ld_t__param1    index ld_v__param2      into ld_v__return.

  read table gd_t__tokenlist index ld_v__start_index assigning <ld_s__tokenlist>.

  create data <ld_s__tokenlist>-refvalue type string.
  assign <ld_s__tokenlist>-refvalue->* to <ld_v__value>.
  <ld_v__value> = ld_v__return.

  <ld_s__tokenlist>-f_variable = abap_true.

endmethod.

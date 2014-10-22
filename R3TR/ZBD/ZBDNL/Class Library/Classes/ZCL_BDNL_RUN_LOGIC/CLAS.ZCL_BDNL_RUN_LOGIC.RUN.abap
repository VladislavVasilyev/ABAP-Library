method RUN.

  data
  : ld_s__stack     type zbnlt_s__stack
  , ld_s__script    type zcl_bdnl_badi_params=>ty_s__script
  .

  field-symbols
  : <ld_s__script>  type zcl_bdnl_badi_params=>ty_s__script
  , <ld_s__for>     type zbnlt_s__for
  .

  break-point.

  loop at  gr_o__params->gd_t__script
     into  ld_s__script
     where run = abap_true.

    message s035(zbdnl).
    message s034(zbdnl) with ld_s__script-appset_id ld_s__script-appl_id ld_s__script-script.

    clear gd_v__turn.

    call method zcl_bdnl_container=>set_current_script
      exporting
        appset_id = ld_s__script-appset_id
        appl_id   = ld_s__script-appl_id
        script    = ld_s__script-script.

    create object gr_o__parser
      exporting
        i_v__appset      = ld_s__script-appset_id
        i_v__application = ld_s__script-appl_id
        i_v__filename    = ld_s__script-script
        i_t__variable    = gr_o__params->gd_t__variable.

    gd_s__stack = gr_o__parser->get_stack( ).

    add 1 to gd_v__script.

    while gd_v__turn < gd_s__stack-turn.
      zcl_bdnl_container=>set_current_for( 0 ).
      add 1 to gd_v__turn.

      zcl_bdnl_container=>set_current_turn( gd_v__turn ).

      clear_containers( ).

      loop at gd_s__stack-for
        assigning <ld_s__for>
        where     turn = gd_v__turn.

        zcl_bdnl_container=>set_current_for( sy-tabix ).

        if <ld_s__for>-packagesize = -1.
          message s038(zbdnl) with <ld_s__for>-tablename `FULL`.
        else.
          message s038(zbdnl) with <ld_s__for>-tablename <ld_s__for>-packagesize.
        endif.

        work_circle( i_s__for = <ld_s__for> ).

        message s049(zbdnl).
      endloop.

    endwhile.
    message s048(zbdnl).
  endloop.

  sort gd_t__containers  by script turn log_turn ascending.

endmethod.

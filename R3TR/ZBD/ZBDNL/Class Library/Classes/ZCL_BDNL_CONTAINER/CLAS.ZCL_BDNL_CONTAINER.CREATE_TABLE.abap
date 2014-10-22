method create_table.

  data
  : ld_s__log                 type ty_s__log
  , ld_f__create              type rs_bool
  .

  field-symbols
  : <ld_s__reestr>            type ty_s__reestr
  .

  case gd_s__param-command.
    when zblnc_keyword-select.

      if f_master = abap_true.
        ld_s__log-sequence = 2.
      else.
        ld_s__log-sequence = 1.
      endif.

      ld_f__create = create_select( package_size ).

    when zblnc_keyword-tablefordown.

      ld_s__log-sequence = 5.

      ld_f__create = create_tablefordown( ).

    when zblnc_keyword-clear.
      ld_s__log-sequence = 0.
      ld_f__create = create_clear( ).
    when zblnc_keyword-ctable.
      ld_s__log-sequence = 4.
      ld_f__create = create_ctable( ).
  endcase.

  ld_s__log-tablename = gd_v__tablename.
  ld_s__log-command   = gd_v__command.
  ld_s__log-n_script  = cd_v__n_script.
  ld_s__log-n_turn    = cd_v__n_turn.
  ld_s__log-n_for     = cd_v__n_for.
  ld_s__log-script    = cd_v__current_script .
  ld_s__log-f_master  = f_master.

  if ld_f__create = abap_true.
    ld_s__log-table    ?= gr_o__container.
  else.
    clear ld_s__log-table.
  endif.

  if ld_s__log-f_master = abap_true.
    insert ld_s__log into table cd_t__log reference into cr_s__log.
  else.
    insert ld_s__log into table cd_t__log.
  endif.
endmethod.

method zif_bd00_int_table~add.
  field-symbols
        : <line>      type any
        , <i_table>   type index table
        , <table>     type any   table
        .

  assign go_target->gr_o__line->line->* to <line>.

  case mode.
    when zbd0c_mode_add_line-collect.
      assign       gref_table->* to   <table>.
      collect <line> into <table> reference into go_rline->line.
    when zbd0c_mode_add_line-insert.
      assign       gref_table->* to   <table>.
      insert <line> into table <table> reference into go_rline->line.
    when zbd0c_mode_add_line-append.
      assign       gref_table->* to   <i_table>.
      append <line> to <i_table> reference into go_rline->line.
  endcase.
  go_rline->f_ref_line = abap_true.
endmethod.

method zif_bd00_int_table~next.
  field-symbols <table> type index table.
  data lr_result type ref to data.

  case gd_v__table_kind.
    when cl_abap_tabledescr=>tablekind_sorted or
         cl_abap_tabledescr=>tablekind_std.

      assign gref_table->* to <table>.

      add_index( ).

      read table <table> index gv_index reference into lr_result.
      if sy-subrc = 0.
        set_result( ir_result = lr_result i_index = gv_index ).
        e_st = zbd0c_found.
      else.
        check lines( <table> ) < gv_index.
        call method clear_index.
        e_st = zbd0c_not_found.
      endif.

    when cl_abap_tabledescr=>tablekind_hashed.
      e_st = next_line( ).
  endcase.
endmethod.

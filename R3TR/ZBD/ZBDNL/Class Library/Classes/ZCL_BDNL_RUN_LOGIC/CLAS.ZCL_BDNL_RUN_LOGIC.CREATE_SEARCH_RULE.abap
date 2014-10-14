method create_search_rule.

  case zcl_bdch_run_new_logic=>cd_v__version.
    when `STABLE`.
      call method create_search_rule__________st
        exporting
          i_s__for    = i_s__for
          i_v__turn   = i_v__turn
        receiving
          e_t__search = e_t__search.
    when `NEW`.
      call method create_search_rule__________nv
        exporting
          i_s__for    = i_s__for
          i_v__turn   = i_v__turn
        receiving
          e_t__search = e_t__search.
  endcase.

endmethod.

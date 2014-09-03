method constructor.

  go_rline          ?= it_rule_link-main->gr_o__line.
  gref_table         = it_rule_link-main->get_ref_table( ).
  go_target         ?= it_rule_link-main.
  gd_v__table_kind   = it_rule_link-main->gr_o__model->gd_s__handle-tab-tech_name->table_kind.

  case it_rule_link-type.
    when method-add.
*      go_line ?= io_line->go_line.
    when method-assign.
*      go_target ?= io_tg.
    when method-search.
*      if io_line is bound.
*        go_line ?= io_line->go_line.
*      endif.
  endcase.
endmethod.

method GET_KF.
  field-symbols: <kf> type uj_keyfigure.
  assign gr_o__line->line->(gr_o__model->gd_v__signeddata) to <kf>.
  check <kf> is assigned.
  kf = <kf>.
endmethod.

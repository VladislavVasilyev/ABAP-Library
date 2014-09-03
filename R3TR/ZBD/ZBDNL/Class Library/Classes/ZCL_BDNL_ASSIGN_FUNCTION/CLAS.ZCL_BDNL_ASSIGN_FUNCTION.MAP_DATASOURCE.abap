method map_datasource.

  data
  : account type string
  .

  account = i01.

  case account.
    when `A_CM_D0_023`. e = `FB_CM`.
    when `A_CM_D0_051`. e = `FB_CM`.
    when `A_CM_I0_001`. e = `FB_CM`.
    when `A_SP_I0_002`. e = `FB_SP`.
    when `A_SP_I0_001`. e = `FB_SP`.
    when `A_SP_D0_001`. e = `FB_SP`.
  endcase.

endmethod.

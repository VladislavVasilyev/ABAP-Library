method map_inventory_mp_curr.

  data
  : account type string
  .

  account = i01.

  case account.
    when `A_IN_D0_001`. e = `LG`.
    when `A_IN_D0_002`. e = `BASE`.
    when others.        e = `LC`.
  endcase.

endmethod.

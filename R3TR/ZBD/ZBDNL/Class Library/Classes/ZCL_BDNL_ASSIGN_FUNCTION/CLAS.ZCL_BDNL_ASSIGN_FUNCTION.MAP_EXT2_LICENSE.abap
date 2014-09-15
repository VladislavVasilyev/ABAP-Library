method map_ext2_license.

*  I01 - формат количество дней
*  I02 - формат YYYYММ00
*  E   - EXT2

  data
  : var1        type sydatum value `19000101`
  , var2        type sydatum
  , var2_str    type string
  , delta_month type i
  .

  var1 = var1 + i01 - 2.
  var2_str = i02 + 1.
  var2 = var2_str.

  break-point.

*  concatenate var1(4) var1+4(2) into var_s_1.
*  var_i_1 = var_s_1.
*  var_i_2 = var2.


  call function 'MONTHS_BETWEEN_TWO_DATES'
    exporting
      i_datum_bis         = var2
      i_datum_von         = var1
*   I_KZ_INCL_BIS       = ' '
   importing
     e_monate            = delta_month.

  case delta_month.
*    when -6. e = `EXT2_SP_030`.
*    when -5. e = `EXT2_SP_031`.
*    when -4. e = `EXT2_SP_032`.
*    when -3. e = `EXT2_SP_033`.
*    when -2. e = `EXT2_SP_034`.
*    when -1. e = `EXT2_SP_035`.
    when  0. e = `EXT2_SP_036`.
    when  1. e = `EXT2_SP_037`.
    when  2. e = `EXT2_SP_038`.
    when  3. e = `EXT2_SP_039`.
    when  4. e = `EXT2_SP_040`.
    when  5. e = `EXT2_SP_041`.
    when  6. e = `EXT2_SP_042`.
    when  7. e = `EXT2_SP_043`.
    when  8. e = `EXT2_SP_044`.
    when  9. e = `EXT2_SP_045`.
    when 10. e = `EXT2_SP_046`.
    when 11. e = `EXT2_SP_047`.
    when others.
      raise exception type zcx_bdnl_skip_assign.
  endcase.

endmethod.

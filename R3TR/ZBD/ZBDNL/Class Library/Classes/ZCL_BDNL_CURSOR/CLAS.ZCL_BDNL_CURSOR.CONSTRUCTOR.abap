method constructor.

*  field-symbols
*  : <ld_s__results>   type match_result
*  : <ld_s__logic>     type  zbnlt_s__lgfsource
*  : <ld_s__tokenlist> type zbnlt_s__match_res
*  .

  gd_t__variable = i_t__variable.
  concatenate i_v__appset `/` i_v__application `/` i_v__filename into  gd_v__script_path.

  call method read_logic
    exporting
      i_v__appset      = i_v__appset
      i_v__application = i_v__application
      i_v__filename    = i_v__filename
    importing
      e_t__logic       = gd_t__logic.

endmethod.

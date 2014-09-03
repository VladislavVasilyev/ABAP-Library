method constructor.

  data
  : ld_t__logic     type zbnlt_t__lgfsource
  , ld_s__logic     type zbnlt_s__lgfsource
  , ld_v__offset    type i
  , ld_t__results   type match_result_tab
  , ld_s__results   type match_result
  , ld_s__length    type i
  , ld_s__length1   type i
  , ld_s__tokenlist type zbnlt_s__match_res
  , ld_s__variable  type zbnlt_s__variable
  , ld_v__value     type string
  , ld_v__i         type i
  .

  field-symbols
  : <ld_s__results>   type match_result
  , <ld_s__logic>     type  zbnlt_s__lgfsource
  , <ld_s__tokenlist> type zbnlt_s__match_res
  .

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

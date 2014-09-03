method set_param.

  data
  : result_tab        type match_result_tab.

  data
  : ld_s__papam       type ujk_s_script_logic_hashentry
  , ld_s__variable    type zbnlt_s__variable
  , ld_s__script      type ty_s__script
  , ld_v__length      type i
  , ld_v__left        type string
  , ld_v__right       type string
  , ld_v__param_rate  type string
  , ld_v__string      type string
  .

  field-symbols
  : <ld_s__cv> type ujk_s_cv
  .

*--------------------------------------------------------------------*
* VARIABLE
*--------------------------------------------------------------------*
  loop at gd_t__param into ld_s__papam
       where hashkey cp `VR(*)`.

    ld_v__length = strlen( ld_s__papam-hashkey ) - 3 - 1.

    concatenate `$` ld_s__papam-hashkey+3(ld_v__length) `$` into ld_s__variable-var.

    ld_s__variable-val = ld_s__papam-hashvalue.
    replace '@' in ld_s__variable-val with ` `.

    insert ld_s__variable into table gd_t__variable.
  endloop.


  loop at gd_t__param into ld_s__papam. " переменные переданы из пакета

    find regex `^\$[A-Z\_][A-Z0-9\_]+\$$` in ld_s__papam-hashkey ignoring case.
    check sy-subrc = 0.
    ld_s__variable-var = ld_s__papam-hashkey.
    ld_s__variable-val = ld_s__papam-hashvalue.
    replace '@' in ld_s__variable-val with ` `.

    insert ld_s__variable into table gd_t__variable.
  endloop.

  if gr_o__replace is bound.

    loop at gd_t__cv  assigning <ld_s__cv>.

      concatenate `%` <ld_s__cv>-dim_upper_case `_SET%` into ld_s__variable-var.

      call method gr_o__replace->replace_dim_set
        exporting
          it_passed_in_region = gd_t__cv
          i_string_statement  = ld_s__variable-var
          i_run_mode          = `EXECUTE`
        importing
          e_result_statement  = ld_s__variable-val.

      insert ld_s__variable into table gd_t__variable.

    endloop.
  endif.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* SCRIPTS
*--------------------------------------------------------------------*
  loop at gd_t__param into ld_s__papam
       where hashkey cp `PR(*)`.

    add 1 to ld_s__script-order.

    ld_s__script-appset_id = gd_v__appset_id.
    ld_s__script-appl_id   = gd_v__appl_id.

    ld_v__length        = strlen( ld_s__papam-hashkey ) - 3 - 1.
    ld_s__script-script = ld_s__papam-hashkey+3(ld_v__length).
    find first occurrence of regex `\<([A-Z0-9\__]+)\/([A-Z0-9\__]+)\/([A-Z0-9\__]+)\.LGF\>` in ld_s__script-script.
    if sy-subrc = 0.
      split ld_s__script-script at `/` into ld_s__script-appset_id ld_s__script-appl_id ld_s__script-script.
    else.
      find first occurrence of regex `\<([A-Z0-9\__]+)\/([A-Z0-9\__]+)\.LGF\>` in ld_s__script-script.
      if sy-subrc = 0.
        split ld_s__script-script at `/` into ld_s__script-appl_id ld_s__script-script.
      else.
        find first occurrence of regex `([A-Z0-9\__]+)\.LGF\>` in ld_s__script-script.
        if sy-subrc <> 0.
          "error
        endif.
      endif.
    endif.

    translate ld_s__papam-hashvalue using `, `.
    condense  ld_s__papam-hashvalue no-gaps.

    find first occurrence of regex `\(([0-1\,]+)\)X\d\=\d` in ld_s__papam-hashvalue.
    if sy-subrc = 0.
      split ld_s__papam-hashvalue at `=` into ld_v__left ld_v__right.
      split ld_v__left at `X` into ld_v__left ld_v__param_rate.

      ld_v__left = ld_v__left+ld_v__param_rate(1).

      if ld_v__left = ld_v__right.
        ld_s__script-run = abap_true.
      else.
        ld_s__script-run = abap_false.
      endif.

      insert ld_s__script into table gd_t__script.
      continue.
    elseif ld_s__papam-hashvalue = `ON` or ld_s__papam-hashvalue = `1`.
      ld_s__script-run = abap_true.
      insert ld_s__script into table gd_t__script.
      continue.
    endif.

  endloop.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* DEBUG
*--------------------------------------------------------------------*
  loop at gd_t__param
       into ld_s__papam
       where hashkey = `DEBUG` or hashkey = `$DEBUG$`.

    if ld_s__papam-hashvalue = `ON`.
      gd_f__debug = abap_true.
      exit.
    else.
      gd_f__debug = abap_false.
    endif.
  endloop.
*--------------------------------------------------------------------*

endmethod.

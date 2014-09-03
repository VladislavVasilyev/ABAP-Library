method READ_LOGIC.

  data
  : lr_o__dispatch      type ref to cl_ujk_dispatch
  , ld_s__search_result type match_result
  , ld_v__filename      type uj_docname
  , ld_t__lgx           type ujk_t_script_logic_scripttable
  , ld_s__lgx           type ujk_s_script_logic_record
  , ld_v__offset        type i
  , ld_v__logic         type zbnlt_s__lgfsource
  .

  refresh e_t__logic.
  find regex '\\ROOT\\WEBFOLDERS' in i_v__filename ignoring case results ld_s__search_result.
  if ld_s__search_result-length is not initial.
    ld_v__filename = i_v__filename.
  else.
    concatenate '\ROOT\WEBFOLDERS\' i_v__appset '\ADMINAPP\' i_v__application '\' i_v__filename into ld_v__filename.
  endif.

  create object lr_o__dispatch.

  select single *
           into corresponding fields of e_s__doc
           from ujf_doc
           where appset  = i_v__appset
             and docname = ld_v__filename.

  if sy-subrc <> 0.
*    raise not_existing.
  endif.

  try.
      call method lr_o__dispatch->validation.

      call method lr_o__dispatch->get_file
        exporting
          i_appset      = i_v__appset
          i_application = i_v__application
          i_user        = ``
          i_filename    = ld_v__filename
        importing
          et_lgx        = ld_t__lgx.

    catch cx_uj_static_check.
*      raise not_existing.
  endtry.

  loop at ld_t__lgx
       into ld_s__lgx.

    append ld_s__lgx-content to e_t__logic.

  endloop.


endmethod.

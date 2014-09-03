function zfm_get_bpc_lgf .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(I_APPSET) TYPE  UJ_APPSET_ID
*"     REFERENCE(I_APPLICATION) TYPE  UJ_APPL_ID
*"     REFERENCE(I_FILENAME) TYPE  UJ_DOCNAME
*"  EXPORTING
*"     REFERENCE(E_DOC) TYPE  UJF_DOC
*"  TABLES
*"      ET_LGF TYPE  ZVCST_T__LGFSOURCE
*"  EXCEPTIONS
*"      NOT_EXISTING
*"----------------------------------------------------------------------

  data
  : lr_o__dispatch      type ref to cl_ujk_dispatch
  , ld_s__search_result type match_result
  , ld_v__filename      type uj_docname
  , ld_t__lgx           type ujk_t_script_logic_scripttable
  , ld_s__lgx           type ujk_s_script_logic_record
  .

  refresh et_lgf.
  find regex '\\ROOT\\WEBFOLDERS' in i_filename ignoring case results ld_s__search_result.
  if ld_s__search_result-length is not initial.
    ld_v__filename = i_filename.
  else.
    concatenate '\ROOT\WEBFOLDERS\' i_appset '\ADMINAPP\' i_application '\' i_filename into ld_v__filename.
  endif.

  create object lr_o__dispatch.

  select single *
           into corresponding fields of e_doc
           from ujf_doc
           where appset  = i_appset
             and docname = ld_v__filename.

  if sy-subrc <> 0.
    raise not_existing.
  endif.

  try.
      call method lr_o__dispatch->validation.

      call method lr_o__dispatch->get_file
        exporting
          i_appset      = i_appset
          i_application = i_application
          i_user        = ``
          i_filename    = ld_v__filename
        importing
          et_lgx        = ld_t__lgx.
    catch cx_uj_static_check.
      raise not_existing.
  endtry.

  loop at ld_t__lgx
       into ld_s__lgx.
    append ld_s__lgx-content to et_lgf.
  endloop.

endfunction.

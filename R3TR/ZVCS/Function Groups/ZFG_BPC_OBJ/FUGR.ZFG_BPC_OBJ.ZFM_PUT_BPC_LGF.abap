function zfm_put_bpc_lgf .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(I_APPSET) TYPE  UJ_APPSET_ID
*"     REFERENCE(I_APPLICATION) TYPE  UJ_APPL_ID
*"     REFERENCE(I_FILENAME) TYPE  UJ_DOCNAME
*"  EXPORTING
*"     REFERENCE(E_DOC) TYPE  UJF_DOC
*"  TABLES
*"      LGF TYPE  ZVCST_T__LGFSOURCE
*"  EXCEPTIONS
*"      NOT_EXISTING
*"      LGF_IS_INITIAL
*"----------------------------------------------------------------------

  data
  : lr_o__dispatch      type ref to cl_ujk_dispatch
  , ld_s__search_result type match_result
  , ld_v__filename      type uj_docname
  , ld_t__lgx           type ujk_t_script_logic_scripttable
  , ld_s__lgx           type ujk_s_script_logic_record
  , lr_o__logic         type ref to cl_uja_logic_lib
  , l_content           type string
  , lx_content          type xstring
  , lo_security         type ref to cl_uje_check_security
  , lv_user	            type uj0_s_user
  .

  try.
      loop at lgf.
        if sy-tabix eq 1.
          l_content = lgf.
        else.
          concatenate l_content cl_abap_char_utilities=>cr_lf lgf into l_content.
        endif.
      endloop.

      call function 'SCMS_STRING_TO_XSTRING'
        exporting
          text     = l_content
          encoding = '4110'
        importing
          buffer   = lx_content
        exceptions
          failed   = 1
          others   = 2.

      create object lo_security.
      lv_user-user_id = lo_security->d_server_admin_id.

      cl_uj_context=>set_cur_context(
        i_appset_id = i_appset
        i_appl_id   = i_application
        is_user     = lv_user ).

      lr_o__logic ?= cl_uja_admin_mgr=>get_logic_lib(
            i_appset_id = i_appset
            i_appl_id   = i_application  ).

      call method lr_o__logic->save_logic
        exporting
          i_doc_name    = i_filename
          i_doc_content = lx_content.

    catch cx_uj_obj_not_found
          cx_uja_admin_error
          cx_uj_no_auth.

  endtry.

endfunction.

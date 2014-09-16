method create_object.

  field-symbols
  : <ld_s__dimn>  type ty_s__dimn
  .

  data
  : ld_s__ujf_doc type ujf_doc
  , ld_s__content type ty_s__content
  , lr_o_dim      type ref to cl_uja_dim
  , lr_i__context type ref to if_uj_context
  .


  loop at gd_t__xml assigning <ld_s__dimn>.
    move-corresponding <ld_s__dimn>-ujf_doc to ld_s__ujf_doc.

    call method cl_gui_frontend_services=>gui_upload
      exporting
        filename   = <ld_s__dimn>-content
        filetype   = `BIN`
      importing
        filelength = ld_s__ujf_doc-doc_length
      changing
        data_tab   = ld_s__content-content
      exceptions
        others     = 24.

    call function 'SCMS_BINARY_TO_XSTRING'
  exporting
    input_length       = ld_s__ujf_doc-doc_length
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
     importing
       buffer             = ld_s__ujf_doc-doc_content
      tables
        binary_tab         = ld_s__content-content
* EXCEPTIONS
*   FAILED             = 1
*   OTHERS             = 2
              .
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    endif.

    data is_user  type uj0_s_user.

    is_user-user_id = `X5`.

    cl_uj_context=>set_cur_context(
    i_appset_id = <ld_s__dimn>-uja_dimension-appset_id
    is_user     = is_user
*    i_appl_id   = gt_cur_context-context->d_appl_id
    ).

    lr_i__context ?= cl_uj_context=>get_cur_context( ).

    lr_i__context->switch_to_srvadmin( ).

    create object lr_o_dim
      exporting
        i_appset_id = <ld_s__dimn>-uja_dimension-appset_id
        i_dimension = <ld_s__dimn>-uja_dimension-dimension.

    lr_o_dim->save_dim_files( i_xls = ld_s__ujf_doc-doc_content if_inc_file_version = abap_true ).
    commit work.
    data lr_o__uja_admin_mgr type ref to cl_uja_admin_mgr.

    create object lr_o__uja_admin_mgr
      exporting
        i_appset_id = <ld_s__dimn>-uja_dimension-appset_id.

*lr_o__uja_admin_mgr->SAVE_DIM_FILES( I_DIMENSION = <ld_s__dimn>-uja_dimension-dimension i_xls = ld_s__ujf_doc-doc_content ).



    data  IT_DIM_LIST	TYPE UJA_T_DIM_NAME.

    append <ld_s__dimn>-uja_dimension-dimension to IT_DIM_LIST.

    lr_o__uja_admin_mgr->process_dimension( IT_DIM_LIST ).

*    lr_o_dim->update_dim_versions( ).
*    lr_o_dim->process_dimension( ).

  endloop.

*  data
*  : ld_s__packages2     type ujd_packages2
*  , ld_s__instructions2 type ujd_instruction2
*  , ld_s__packagest2    type ujd_packagest2
*  , ld_v__guid          type uj0_uni_idc32
*  , gd_v__tmstp         type tzntstmpl
*  , gd_v__time          type string
*  , gd_v__date          type string
*  , ld_s__lang          type ty_s__langu
*  .
*
*  field-symbols
*  : <ls_s__pack>        type ty_s__pack
*  , <ls_v__source>      type string
*  .
*
*  assign i_r__source to <ls_s__pack>.
*
*  move-corresponding <ls_s__pack> to ld_s__packages2.
*
*  loop at <ls_s__pack>-source
*       assigning <ls_v__source>.
*    if sy-tabix = 1.
*      get time stamp field gd_v__tmstp.
*      convert time stamp gd_v__tmstp time zone cs_time_zone  into: time gd_v__time, date gd_v__date.
*
*      concatenate
*        `'@ Upload from PC. User `
*        sy-uname   `, `
*        gd_v__date+0(4) `.`
*        gd_v__date+4(2) `.`
*        gd_v__date+6(2) ` `
*        gd_v__time+0(2) `:`
*        gd_v__time+2(2) `:`
*        gd_v__time+4(2) `.<BR>`
*        into ld_s__instructions2-content.
*
*      find first occurrence of `'@` in section offset 0 of <ls_v__source>.
*      if sy-subrc ne 0.
*        concatenate ld_s__instructions2-content <ls_v__source> into ld_s__instructions2-content.
*      endif.
*    else.
*      concatenate ld_s__instructions2-content `<BR>` <ls_v__source> into ld_s__instructions2-content.
*    endif.
*  endloop.
*
*  select single guid
*    from ujd_packages2
*    into ld_v__guid
*    where appset_id   = ld_s__packages2-appset_id
*      and app_id      = ld_s__packages2-app_id
*      and team_id     = ld_s__packages2-team_id
*      and group_id    = ld_s__packages2-group_id
*      and package_id  = ld_s__packages2-package_id.
*
*  ld_s__instructions2-appset_id = ld_s__packages2-appset_id.
*
*  if sy-subrc eq 0." если пакет уже существует
*    ld_s__instructions2-guid = ld_v__guid.
*    if ld_s__instructions2-content is not initial.
*      modify ujd_instruction2 from ld_s__instructions2.
*    endif.
*  else. " если пакета не существует
*    cl_uj_services=>generate_guid( importing e_uni_idc32 = ld_v__guid ). " create GUID
*    ld_s__packages2-guid      = ld_v__guid.
*    ld_s__instructions2-guid  = ld_v__guid.
*
*    modify ujd_packages2    from ld_s__packages2.
*
*    if ld_s__instructions2-content is not initial.
*      modify ujd_instruction2 from ld_s__instructions2.
*    endif.
*  endif.
*
*  if <ls_s__pack>-langu is not initial.
*    loop at <ls_s__pack>-langu
*         into ld_s__lang.
*
*      ld_s__packagest2-guid         = ld_v__guid.
*      ld_s__packagest2-langu        = ld_s__lang-langu.
*      ld_s__packagest2-package_desc = ld_s__lang-package_desc.
*      ld_s__packagest2-appset_id    = ld_s__packages2-appset_id.
*
*      modify ujd_packagest2 from ld_s__packagest2.
*    endloop.
*  endif.

endmethod.

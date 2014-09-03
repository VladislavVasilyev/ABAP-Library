method READ_OBJECT.

*  data
*  : l_enhspothd       type standard table of enhspotheader
*  , ls_enhspothd      type standard table of enhspotheader
*  .
*
*  field-symbols
*  : <header> type enhspotheader
*  .
*
*  data :
*  l_text_tab        type enh_cwb_stext_tab,
*  l_string_tab      type enh_cwb_ltext_tab,
*  l_header          type enh_cwb_htext,
*  l_xstr_text_tab   type xstring,
*  l_xstr_string_tab type xstring,
*  l_xstr_header     type xstring,
*  l_xstr_out        type xstring,
*  l_data_tb_x       type enh_version_management_hex_tb,
*  l_data_x          type enh_version_management_hex,
*  l_idx             type sy-tabix,
*  l_textvers        type      enhtext_vers,
*  l_textversdata    type      enhtext_versdata.
*
*
*
*
** get header data
*  select  * from enhspotheader into table l_enhspothd
*             where enhspot = `ZES_RUN_PACKAGE_FOR_BPC`
*               and version = `A`.
*
*  loop at l_enhspothd assigning <header>.
*
*    call function 'ENH_GET_SCWB_TEXT'
*      exporting
*        i_docuid                = <header>-shorttextid
*       i_langu                  = i_s__tadir-masterlang
*        i_docu_type             = `S`
*     IMPORTING
*       v_text_tab              = l_text_tab[]
*       v_string_tab            = l_string_tab[]
*       v_header                = l_header
**     EXCEPTIONS
**       CONCEPT_NOT_FOUND       = 1
**       TEXT_NOT_FOUND          = 2
**       ERROR                   = 3
**       OTHERS                  = 4
*              .
*    if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    endif.
*
*
*
*  endloop.


endmethod.

*&---------------------------------------------------------------------*
*&  Include           ZZFG_BD00_F01
*&---------------------------------------------------------------------*
form create_ref_infocube using    i_t_sfc   type rsdri_th_sfc
                                  i_t_sfk   type rsdri_th_sfk
                         changing lr_t_data type ref to data.

  data
      : ls_sfc          like line of i_t_sfc
      , ls_sfk          like line of i_t_sfk
      , lv_chanm        type rschanm
      , lv_attrinm      type rsattrinm
      , lt_comp         type abap_component_tab
      , ls_comp         type abap_componentdescr
      , lr_s_data       type ref to data
      , lo_struct       type ref to cl_abap_structdescr
      , l_s_cob_pro     type rsd_s_cob_pro
      .

  field-symbols
      : <lt_data>       type any table
      , <ls_data>       type any
      .

*--------------------------------------------------------------------*
* Обработка признаков
*--------------------------------------------------------------------*
  loop at i_t_sfc
       into ls_sfc.

    split ls_sfc-chanm at `__` into lv_chanm lv_attrinm.

    ls_comp-name = ls_sfc-chaalias.

    if lv_attrinm is not initial.
      call function 'RSD_IOBJ_GET'
        exporting
          i_iobjnm    = lv_attrinm
        importing
          e_s_cob_pro = l_s_cob_pro.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( l_s_cob_pro-dtelnm ).
    else.
      call function 'RSD_IOBJ_GET'
        exporting
          i_iobjnm    = lv_chanm
        importing
          e_s_cob_pro = l_s_cob_pro.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( l_s_cob_pro-dtelnm ).
    endif.

    append ls_comp to lt_comp.
  endloop.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Обработка показателей
*--------------------------------------------------------------------*
  loop at i_t_sfk
       into ls_sfk.

    ls_comp-name  = ls_sfk-kyfalias.
    if ls_sfk-kyfalias = `1ROWCOUNT`.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( 'RSSID' ).
    else.
      call function 'RSD_IOBJ_GET'
        exporting
          i_iobjnm    = ls_sfk-kyfnm
        importing
          e_s_cob_pro = l_s_cob_pro.
      ls_comp-type ?= cl_abap_datadescr=>describe_by_name( l_s_cob_pro-dtelnm ).
    endif.
    append ls_comp to lt_comp.
  endloop.
*--------------------------------------------------------------------*

  lo_struct = cl_abap_structdescr=>create( p_components = lt_comp
                                           p_strict     = abap_false ).

  create data lr_s_data type handle lo_struct.
  assign lr_s_data->*   to   <ls_data>.

  create data lr_t_data like standard table of <ls_data> with non-unique default key.
endform.                    "create_ref_infocube

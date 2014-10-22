*----------------------------------------------------------------------*
*       CLASS ZCL_BD00_MODEL  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zcl_bd00_model definition
  public
  final
  create private

  global friends zcl_bd00_appl_line
                 zcl_bd00_appl_table .

*"* public components of class ZCL_BD00_MODEL
*"* do not include other source files here!!!
  public section.
    type-pools zbd0c .
    type-pools zbd0t .

    types:
      begin of ty_s_alias.
    types tech_name type rschanm.
    types tech_alias type rsalias.
    types end of ty_s_alias .
    types:
      ty_t_alias type hashed table of ty_s_alias with unique key tech_alias .
    types:
      begin of ty_s_dim_list.
    include type zbd00_s_dimn.
    types orderby type zbd00_s_ch_key-orderby.
    types f_key type zbd00_s_ch_key-f_key.
    types ty_elem type ref to cl_abap_datadescr.
    types end   of ty_s_dim_list .
    types:
      ty_t_dim_list type hashed table of ty_s_dim_list
                              with unique key dimension attribute .
    types:
      begin of ty_s_key_list
              , nkey type zbd00_s_bpc_dim-nkey
              , type type zbd00_s_bpc_dim-type
              , dimensions type ty_t_dim_list
            , end   of ty_s_key_list .
    types:
      ty_t_key_list type sorted table of ty_s_key_list with unique key nkey .

    constants:
      cs_pk type c value `PK` length 2 .
    type-pools abap .
    data gd_f__complete_key type rs_bool read-only value abap_true. "#EC NOTEXT .
    data gd_f__write_on type rs_bool read-only .
    data gr_o__application type ref to zcl_bd00_application read-only .
    data gr_t__dimension type ref to ty_t_dim_list read-only .
    data:
      begin of gd_s__handle read-only.
    data begin of st.
    data appl_name type ref to cl_abap_structdescr.
    data tech_name type ref to cl_abap_structdescr.
    data end of st.
    data begin of tab.
    data appl_name type ref to cl_abap_tabledescr.
    data tech_name type ref to cl_abap_tabledescr.
    data end of tab.
    data end of gd_s__handle .
    data gd_t__key_list type ty_t_key_list read-only .
    data gd_t__sfc type rsdri_t_sfc read-only .
    data gd_t__sfk type rsdri_t_sfk read-only .
    data gd_v__signeddata type uj_dim_name read-only .
    data gd_t__signeddata type zbd0t_ty_t_kf read-only .
    data gd_v__type_pk type zbd00_type_appl_table read-only .
    data gd_t__dim_list type zbd00_st_ch_key read-only .
    data gd_t__components type abap_keydescr_tab read-only .
    data gd_t__key type abap_keydescr_tab read-only .
    data gd_t__tech_alias type ty_t_alias read-only .
    data gd_t__bpc_alias type zbd00_t_alias read-only .
    data gd_v__comp_uc type xstring read-only .

    methods get_tech_alias
      importing
        !dimension type uj_dim_name
        !attribute type uj_attr_name optional
      returning
        value(alias) type rsalias .
    methods get_dtelnm
      importing
        !dimension type uj_dim_name
        !attribute type uj_attr_name optional
      returning
        value(dtelnm) type rollname .
    methods get_dim_name
      importing
        !tech_alias type rsalias
      returning
        value(dim_name) type zbd0t_ty_s_dim .
    methods get_appl
      returning
        value(result) type ref to zcl_bd00_application .
    class-methods get_model
      importing
        !it_dim_list type zbd00_t_ch_key optional
        !i_appset_id type uj_appset_id optional
        !i_appl_id type uj_appl_id optional
        !i_type_pk type zbd00_s_bpc_dim-type default zbd0c_ty_tab-std_non_unique_dk
        !it_alias type zbd00_t_alias optional
      returning
        value(e_obj) type ref to zcl_bd00_model
      raising
        zcx_bd00_create_obj .
    class-methods get_model_cust_appl
      importing
        !it_dim_list type zbd00_t_ch_key optional
        !i_appset_id type uj_appset_id optional
        !i_type_pk type zbd00_s_bpc_dim-type default zbd0c_ty_tab-std_non_unique_dk
        !it_alias type zbd00_t_alias optional
      returning
        value(e_obj) type ref to zcl_bd00_model
      raising
        zcx_bd00_create_obj .
    class-methods get_model_dimension
      importing
        !it_dim_list type zbd00_t_ch_key optional
        !i_appset_id type uj_appset_id optional
        !i_type_pk type zbd00_s_bpc_dim-type default zbd0c_ty_tab-std_non_unique_dk
        !it_alias type zbd00_t_alias optional
        !i_dimension type uj_dim_name optional
      returning
        value(e_obj) type ref to zcl_bd00_model
      raising
        zcx_bd00_create_obj .
    class-methods get_model_infocube
      importing
        !it_dim_list type zbd00_t_ch_key optional
        !i_type_pk type zbd00_s_bpc_dim-type default zbd0c_ty_tab-std_non_unique_dk
        !it_alias type zbd00_t_alias optional
        !i_infocube type rsinfoprov
        !it_kyf_list type zbd0t_ty_t_kf optional
      returning
        value(e_obj) type ref to zcl_bd00_model
      raising
        zcx_bd00_create_obj .

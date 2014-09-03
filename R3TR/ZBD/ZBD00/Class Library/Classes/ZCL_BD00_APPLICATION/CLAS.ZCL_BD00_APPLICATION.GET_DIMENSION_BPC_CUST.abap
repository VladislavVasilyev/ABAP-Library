method get_dimension_bpc_cust.
  break-point id zbd00.

  types: begin of ty_s__st
         , dimension type uj_dim_name
         , tech_name type rsatrnavnm
         , end of ty_s__st.

  data
  : ls_dimension          type zbd00_s_dimn
  , l_dimension           type uj_dim_name
  , l_s_cob_pro           type rsd_s_cob_pro
  , l_ioobj               type rsd_iobjnm
  , l_tech_name           type uj_tech_name
  , ld_t__dimension       type standard table of ty_s__st
  .

  field-symbols
  : <ld_s__dimension>     type ty_s__st
  .

  check gd_t__dimensions is initial.

  select dimn~dimension as dimension dimn~tech_name as tech_name
    into corresponding fields of table ld_t__dimension "(ls_dimension-dimension, ls_dimension-tech_name)
         from  uja_dim_appl       as appl
         inner join uja_dimension as dimn
               on appl~appset_id = dimn~appset_id and
                  appl~dimension = dimn~dimension
    where appl~appset_id      = gd_v__appset_id
    group by dimn~dimension dimn~tech_name
    order by dimn~dimension.

  loop at ld_t__dimension assigning <ld_s__dimension>.

    ls_dimension-dimension = <ld_s__dimension>-dimension.
    ls_dimension-tech_name = <ld_s__dimension>-tech_name.

    l_ioobj = ls_dimension-tech_name .

    call function 'RSD_IOBJ_GET'
      exporting
        i_iobjnm    = l_ioobj
      importing
        e_s_cob_pro = l_s_cob_pro.

    ls_dimension-type       = cs_dm.
    ls_dimension-dtelnm     = l_s_cob_pro-dtelnm.
    ls_dimension-tech_alias = ls_dimension-tech_name.

    insert ls_dimension into table gd_t__dimensions.

    l_tech_name = ls_dimension-tech_name.
    l_dimension = ls_dimension-dimension.

    select dimension tech_name attribute_name
         from uja_dim_attr
         into (ls_dimension-dimension, ls_dimension-tech_name, ls_dimension-attribute)
         where appset_id      = gd_v__appset_id and
               dimension      = l_dimension and
               attribute_type = `NAV`
         order by attribute_name.

      l_ioobj = ls_dimension-tech_name .

      select single atrnavnm sidfieldnm
         from rsdatrnavsid
         into (ls_dimension-tech_name, ls_dimension-tech_alias)
         where chanm   = l_tech_name and
               attrinm = ls_dimension-tech_name .

      call function 'RSD_IOBJ_GET'
        exporting
          i_iobjnm    = l_ioobj
        importing
          e_s_cob_pro = l_s_cob_pro.

      ls_dimension-type    = cs_an.
      ls_dimension-dtelnm  = l_s_cob_pro-dtelnm.

      insert ls_dimension into table gd_t__dimensions.

    endselect.
    clear ls_dimension.
  endloop.

*--------------------------------------------------------------------*
* Key FIGURES
*--------------------------------------------------------------------*
  ls_dimension-dimension  = uj00_cs_fieldname-signeddata.
  ls_dimension-tech_name  = uj00_cs_iobj-signeddata.
  ls_dimension-tech_alias = uj00_cs_iobj-signeddata.
  ls_dimension-type       = cs_kf.

  l_ioobj = ls_dimension-tech_name .

  call function 'RSD_IOBJ_GET'
    exporting
      i_iobjnm    = l_ioobj
    importing
      e_s_cob_pro = l_s_cob_pro.

  ls_dimension-dtelnm  = l_s_cob_pro-dtelnm.

  insert ls_dimension into table gd_t__dimensions.

endmethod.

method get_dimension_bp.
  break-point id zbd00.

  data
  : ls_dimension          type zbd00_s_dimn
  , ld_v__iobjnm          type rsiobjnm
  , l_dimension           type uj_dim_name
  , l_s_cob_pro           type rsd_s_cob_pro
  , l_ioobj               type rsd_iobjnm
  , l_tech_name           type uj_tech_name
  , ld_t__kyf             type zbd00_t_dimn
  .

  field-symbols
  : <ls_dimension>        type zbd00_s_dimn
  .

  check gd_t__dimensions is initial.

  select  iobjnm
    into  ld_v__iobjnm
    from  rsdcubeiobj
    where infocube = gd_v__infoprovide
      and objvers = `A`
    order by iobjnm.

    clear ls_dimension.

    select single atrnavnm chanm attrinm sidfieldnm
           from rsdatrnavsid
           into (ls_dimension-tech_name, ls_dimension-dimension, ls_dimension-attribute, ls_dimension-tech_alias)
           where atrnavnm = ld_v__iobjnm.

    if sy-subrc = 0.
      l_ioobj = ls_dimension-attribute .

      call function 'RSD_IOBJ_GET'
        exporting
          i_iobjnm    = l_ioobj
        importing
          e_s_cob_pro = l_s_cob_pro.

      ls_dimension-type       = cs_an.
      ls_dimension-dtelnm     = l_s_cob_pro-dtelnm.

      insert ls_dimension into table gd_t__dimensions.
    else.
      l_ioobj = ld_v__iobjnm .

      call function 'RSD_IOBJ_GET'
        exporting
          i_iobjnm    = l_ioobj
        importing
          e_s_cob_pro = l_s_cob_pro.

      ls_dimension-dimension  = ld_v__iobjnm.
      ls_dimension-tech_name  = ld_v__iobjnm.
      ls_dimension-dtelnm     = l_s_cob_pro-dtelnm.
      ls_dimension-tech_alias = ls_dimension-tech_name.


      if l_s_cob_pro-iobjtp = `KYF`.
        ls_dimension-type       = cs_kf.
        insert ls_dimension into table ld_t__kyf.
      else.
        ls_dimension-type       = cs_dm.
        insert ls_dimension into table gd_t__dimensions.
      endif.
    endif.
  endselect.

  check ld_t__kyf is not initial.
  insert lines of ld_t__kyf into table gd_t__dimensions.

  loop at gd_t__dimensions assigning <ls_dimension>.
    case <ls_dimension>-tech_alias+0(1).
      when `0`.
        <ls_dimension>-tech_alias+0(1) = `A`.
    endcase.
  endloop.


endmethod.

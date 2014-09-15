method constructor.

  break-point id zbd00.

  data ls_reestr like line of reestr.

*--------------------------------------------------------------------*
* Check APPSET if supplied
*--------------------------------------------------------------------*
  if i_appset_id is supplied.
*--------------------------------------------------------------------*
* CHECK APPSET_ID
*--------------------------------------------------------------------*
    select single appset_id
      into gd_v__appset_id
      from uja_appset_info
      where appset_id = i_appset_id.

    if sy-subrc ne 0.
      raise exception type zcx_bd00_create_obj
            exporting textid      = zcx_bd00_create_obj=>ex_appset_not_found
                      i_appset_id = i_appset_id.
    endif.
  endif.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Create APPLICATION
*--------------------------------------------------------------------*
  if i_appset_id is supplied and i_appl_id is supplied.
*--------------------------------------------------------------------*
* CHECK APPL_ID
*--------------------------------------------------------------------*
    select single *
      into corresponding fields of gd_s__appl_info
      from uja_appl
      where appset_id      = gd_v__appset_id and
            application_id = i_appl_id.

    if sy-subrc ne 0.
      raise exception type zcx_bd00_create_obj
            exporting textid      = zcx_bd00_create_obj=>ex_appl_not_found
                      i_appset_id = i_appset_id
                      i_appl_id   = i_appl_id.
    endif.

    gd_v__appl_id     = gd_s__appl_info-application_id.
    gd_v__infoprovide = gd_s__appl_info-infocube.

*--------------------------------------------------------------------*

    select  single description
      into  corresponding fields of gd_s__appl_info
      from  uja_applt
      where langu          = cl_uj_dao_env=>g_langu and
            appset_id      = gd_v__appset_id        and
            application_id = i_appl_id.

    get_dimension_bpc( ).

    ls_reestr-appset_id  = i_appset_id.
    ls_reestr-appl_id    = i_appl_id.
    ls_reestr-obj        = me.

    insert ls_reestr into table reestr.


*    gd_v__package_size = 53000.

    select single value
      from ujr_param
      into gd_v__package_size
      where appset_id = i_appset_id and
            application_id = i_appl_id and
            param = `PACKAGE_SIZE`.

      if sy-subrc ne 0.
       gd_v__package_size = 40000.
      endif.

    return.
  endif.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* CREATE DIMENSION
*--------------------------------------------------------------------*
  if i_appset_id is supplied and i_dimension is supplied.
*--------------------------------------------------------------------*
* CHECK DIMENSION
*--------------------------------------------------------------------*
    select single dimension
      from uja_dimension
      into gd_v__dimension
     where appset_id = i_appset_id
       and dimension = i_dimension.

    if sy-subrc ne 0.
      raise exception type zcx_bd00_create_obj
            exporting textid      = zcx_bd00_create_obj=>ex_appset_not_found
                      i_appset_id = gd_v__appset_id
                      i_dim_name  = i_dimension.
    endif.

    get_dimension_mbr( ).

    ls_reestr-appset_id  = i_appset_id.
    ls_reestr-dimension  = gd_v__dimension.
    ls_reestr-obj        = me.

    insert ls_reestr into table reestr.

    return.
  endif.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* CREATE CUSTOM APPLICATION
*--------------------------------------------------------------------*
  if i_appset_id is supplied and i_dimension is not supplied and i_appl_id is not supplied.

    get_dimension_bpc_cust( ).

    ls_reestr-appset_id  = i_appset_id.
    ls_reestr-appl_id    = space.
    ls_reestr-obj        = me.

    insert ls_reestr into table reestr.
    return.
  endif.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* CREATE INFOCUBE
*--------------------------------------------------------------------*
  if i_infocube is supplied.
*--------------------------------------------------------------------*
* CHECK INFOPROVIDE
*--------------------------------------------------------------------*
    select single infocube
           from rsdcube
           into gd_v__infoprovide
           where infocube = i_infocube
             and objvers = `A`.

    if sy-subrc ne 0.
      raise exception type zcx_bd00_create_obj
            exporting textid      = zcx_bd00_create_obj=>ex_infoprov_not_found
                      i_infoprovide = i_infocube.
    endif.

    get_dimension_bp( ).

    ls_reestr-infocube   = i_infocube.
    ls_reestr-obj        = me.

    insert ls_reestr into table reestr.
    return.
  endif.
*--------------------------------------------------------------------*

endmethod.

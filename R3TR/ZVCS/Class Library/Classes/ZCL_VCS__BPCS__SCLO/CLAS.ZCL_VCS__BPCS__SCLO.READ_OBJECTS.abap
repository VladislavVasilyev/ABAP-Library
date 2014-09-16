method read_objects.

  data
  : ld_s__ujfdoc              type ujf_doc
  , lr_x__call_module_error   type ref to zcx_vcs__call_module_error
  , ld_v__docname             type uj_docname
  , ld_s__sclo                type ty_s__sclo
  , ld_s__source              type zvcst_s__download
  , txtsource                 type zvcst_s__source_path
  .

  field-symbols
  : <ld_s__sclo>              type ty_s__sclo
  , <ld_s__xml1>              type ty_s__sclo
  .


  loop at gd_t__sclo assigning <ld_s__sclo>.

    try.
        call method zcl_vcs_bpc___tech=>zfm_get_bpc_lgf
          exporting
            i_appset      = <ld_s__sclo>-appset
            i_application = <ld_s__sclo>-application
            i_filename    = <ld_s__sclo>-filename
          importing
*            e_doc         = ld_s__ujfdoc
            et_lgf        = <ld_s__sclo>-source.

**********************************************************************
* Save TXT
**********************************************************************
        data ld_s__txtsource type zvcst_s__source_path.

        ld_s__txtsource-pathnode = `/SOURCE`.
*      ld_s__txtsource-pathname = `/METHODS/item/CMPKEY/CMPNAME`.
        append  ld_s__txtsource to ld_s__source-txtnodepath.


        ld_s__source-header-appset         = <ld_s__sclo>-appset.
        ld_s__source-header-application    = <ld_s__sclo>-application.
        ld_s__source-header-pgmid          = ld_s__source-type-pgmid   = zvcsc_bpc.
        ld_s__source-header-object         = ld_s__source-type-object  = zvcsc_bpc_type-sclo.
        ld_s__source-header-obj_name       = <ld_s__sclo>-filename.
        clear <ld_s__sclo>-filename.


        create data ld_s__source-xmlsource type ty_s__sclo.
        assign ld_s__source-xmlsource->* to <ld_s__xml1>.
        <ld_s__xml1> = <ld_s__sclo>.

        append ld_s__source to gd_t__source.


      catch zcx_vcs__call_module_error into lr_x__call_module_error.
*        raise exception type zcx_vcs_objects_read__bpc
*          exporting
*            previous       = lr_x__call_module_error
*            object         = i_s__tadir-object
*            obj_name       = i_s__tadir-obj_name
*            appset_id      = i_s__tadir-appset
*            application_id = i_s__tadir-application.
    endtry.


  endloop.

endmethod.

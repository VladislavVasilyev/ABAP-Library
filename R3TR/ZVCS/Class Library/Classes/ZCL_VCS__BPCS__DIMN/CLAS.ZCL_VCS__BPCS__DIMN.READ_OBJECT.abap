method READ_OBJECT.

  types: begin of ty_s__selpack.
    include type ujd_packages2.
  types: content type string
         , end of ty_s__selpack
         .

*  data
*  : ld_s__selpack           type ty_s__selpack
*  , ld_s__instruction       type ujd_instruction
*  , lr_x__call_module_error type ref to zcx_vcs__call_module_error
*  , ld_v__team_id           type uj_team_id
*  , ld_v__group_id          type uj_pack_grp_id
*  , ld_v__package_id        type uj_package_id
*  , ld_s__lang              type ty_s__langu
*  , ld_s__pack              type ty_s__pack
*  .


*  try.
*
*      split i_s__tadir-obj_name at `/` into ld_v__team_id ld_v__group_id ld_v__package_id.
*
*      select single  *
*        from ujd_packages2 as pack
*        into corresponding fields of ld_s__selpack
*        where pack~appset_id  = i_s__tadir-appset
*          and pack~app_id     = i_s__tadir-application
*          and pack~team_id    = ld_v__team_id
*          and pack~group_id   = ld_v__group_id
*          and pack~package_id = ld_v__package_id.
*
** Select Text
*      select langu package_desc
*          into corresponding fields of ld_s__lang
*          from ujd_packagest2
*          where guid = ld_s__selpack-guid.
*
*        check ld_s__lang-package_desc is not initial.
*        insert ld_s__lang into table ld_s__pack-langu.
*      endselect.
*
*
*      " Select Content
*      select single content
*         from ujd_instruction2
*         into ld_s__selpack-content
*         where guid = ld_s__selpack-guid.
*
*      if sy-subrc <> 0.
*        select *
*          from ujd_instruction
*          into corresponding fields of ld_s__instruction
*          where chain_id = ld_s__selpack-chain_id.
*
*          if ld_s__instruction-appset_id = ld_s__selpack-appset_id and
*             ld_s__instruction-appl_id = ld_s__selpack-app_id.
*            exit.
*          endif.
*        endselect.
*
*        ld_s__selpack-content = ld_s__instruction-content.
*      endif.
*
*
*      move-corresponding ld_s__selpack to ld_s__pack.
*      split ld_s__selpack-content at `<BR>` into table ld_s__pack-source.
*
***********************************************************************
** Save TXT
***********************************************************************
*      data ld_s__txtsource type zvcst_s__source_path.
*
*      ld_s__txtsource-pathnode = `/SOURCE`.
**      ld_s__txtsource-pathname = `/METHODS/item/CMPKEY/CMPNAME`.
*      append  ld_s__txtsource to e_t__txtsource.
*
*
*      e_s__source = ld_s__pack.
*
*    catch zcx_vcs__call_module_error into lr_x__call_module_error.
*      raise exception type zcx_vcs_objects_read__bpc
*        exporting
*          object         = i_s__tadir-object
*          obj_name       = i_s__tadir-obj_name
*          appset_id      = i_s__tadir-appset
*          application_id = i_s__tadir-application.
*  endtry.

endmethod.

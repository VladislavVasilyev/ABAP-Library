method set_task_download_for_bpc.

  data
  : ld_v__appset            type uj_appset_id
  , ld_v__application       type uj_appl_id
  , ld_v__docname           type uj_docname
  , ld_v__package_id        type uj_package_id
  , ld_v__group_id          type uj_pack_grp_id
  , ld_v__team_id           type uj_team_id
  , ld_v__splitdoc          type table of string
  , ld_v__srchstr           type string
  , ld_s__task_stack        type zvcst_s__tadir
  , ld_t__appset            type standard table of uj_appset_id with non-unique default key
  , ld_t__application       type standard table of uj_appl_id with non-unique default key
  , ld_t__docname           type standard table of uj_docname with non-unique default key
  , ld_v__string            type string
  .


  zcl_vcs_objects_stack=>cd_r__appl_id   = i_t__appl_id.
  zcl_vcs_objects_stack=>cd_r__appset_id = i_t__appset_id.
  zcl_vcs_objects_stack=>cd_r__dimension = i_t__dimension.
  zcl_vcs_objects_stack=>cd_f__lgf  = i_f__lgf.
  zcl_vcs_objects_stack=>cd_f__pack = i_f__pack.
  zcl_vcs_objects_stack=>cd_f__xltp = i_f__xltp.
  zcl_vcs_objects_stack=>cd_f__dimn = i_f__dimn.

  field-symbols
  : <ld_s__bpcdir>    type zvcst_s__tadir
  .

  cd_v__path = i_s__path.

  " select appset's
  select appset_id
         from uja_appset_info
         into table ld_t__appset
         where appset_id in i_t__appset_id.

  loop at ld_t__appset into ld_v__appset.
    clear ld_s__task_stack.
    ld_s__task_stack-obj_name = ld_v__appset.
    ld_s__task_stack-appset   = ld_v__appset.
    ld_s__task_stack-pgmid    = zvcsc_bpc.
    ld_s__task_stack-object   = zvcsc_bpc_type-apps.

    insert ld_s__task_stack into table zcl_vcs_objects_stack=>cd_t__task_stack .

    " select application
    select application_id
          from uja_appl
          into table ld_t__application
          where appset_id = ld_v__appset
            and application_id in i_t__appl_id .

    loop at ld_t__application into ld_v__application.
      clear ld_s__task_stack.
      ld_s__task_stack-obj_name     = ld_v__application.
      ld_s__task_stack-appset       = ld_v__appset.
      ld_s__task_stack-application  = ld_v__application.
      ld_s__task_stack-pgmid        = zvcsc_bpc.
      ld_s__task_stack-object       = zvcsc_bpc_type-appl.

      insert ld_s__task_stack into table zcl_vcs_objects_stack=>cd_t__task_stack.

      if i_f__lgf = abap_true.

        " select lgf
        concatenate `%` ld_v__application `%` into ld_v__srchstr.

        select docname
               into table ld_t__docname
               from ujf_doc
               where appset       eq ld_v__appset
                 and docname like ld_v__srchstr
                 and doctype      eq `LGF`
                 and compression  ne `X`.

        loop at ld_t__docname into ld_v__docname.
          ld_s__task_stack-appset = ld_v__appset.
          ld_s__task_stack-object = zvcsc_bpc_type-sclo.

          clear ld_v__splitdoc.
          split ld_v__docname at `\` into table ld_v__splitdoc.

          read table ld_v__splitdoc index 6 into ld_s__task_stack-application.
          check ld_s__task_stack-application = ld_v__application.

          read table ld_v__splitdoc index 7 into ld_s__task_stack-obj_name.

          insert ld_s__task_stack into table zcl_vcs_objects_stack=>cd_t__task_stack.

        endloop.
      endif.

      if i_f__xltp = abap_true.
        concatenate `%` ld_v__application `%` into ld_v__srchstr.

        select ujf_doc~docname
          into table ld_t__docname
          from ujf_doc
           inner join ujf_doctree on ujf_doc~appset = ujf_doctree~appset and
                                     ujf_doc~docname = ujf_doctree~docname
          where ujf_doc~appset       eq ld_v__appset
            and ujf_doc~docname like ld_v__srchstr
            and ( ujf_doc~doctype      like `XL_`
             or   ujf_doc~doctype      like `XL__` ).


        loop at ld_t__docname into ld_v__docname.
          ld_s__task_stack-appset = ld_v__appset.
          ld_s__task_stack-object = zvcsc_bpc_type-xltp.

          clear ld_v__splitdoc.
          split ld_v__docname at `\` into table ld_v__splitdoc.

          read table ld_v__splitdoc index 6 into ld_s__task_stack-application.
          check ld_s__task_stack-application = `EEXCEL`.

          read table ld_v__splitdoc index 5 into ld_s__task_stack-application.
          check ld_s__task_stack-application = ld_v__application.

          loop at ld_v__splitdoc into ld_v__string from 7.
            if sy-tabix = 7.
              ld_s__task_stack-obj_name = ld_v__string.
            else.
              concatenate ld_s__task_stack-obj_name `\` ld_v__string  into ld_s__task_stack-obj_name.
            endif.
          endloop.

          insert ld_s__task_stack into table zcl_vcs_objects_stack=>cd_t__task_stack.

        endloop.
      endif.


      if i_f__pack = abap_true.

        select team_id group_id package_id
          into (ld_v__team_id, ld_v__group_id, ld_v__package_id)
          from ujd_packages2
          where appset_id = ld_v__appset
            and app_id = ld_v__application
            and package_id <> ``
            and team_id <> `INSTALLATION`.

          clear ld_s__task_stack.
          ld_s__task_stack-pgmid        = zvcsc_bpc.
          ld_s__task_stack-appset       = ld_v__appset.
          ld_s__task_stack-application  = ld_v__application.

          concatenate ld_v__team_id `/` ld_v__group_id `/` ld_v__package_id into: ld_s__task_stack-obj_name.
          ld_s__task_stack-object = zvcsc_bpc_type-pack.

          insert ld_s__task_stack into table zcl_vcs_objects_stack=>cd_t__task_stack.

        endselect.
      endif.

      if i_f__dimn   = abap_true.



      endif.

    endloop.

  endloop.

endmethod.

method CREATE_OBJECT.

  data
  : ld_s__packages2     type ujd_packages2
  , ld_s__instructions2 type ujd_instruction2
  , ld_s__packagest2    type ujd_packagest2
  , ld_v__guid          type uj0_uni_idc32
  , gd_v__tmstp         type tzntstmpl
  , gd_v__time          type string
  , gd_v__date          type string
  , ld_s__lang          type ty_s__langu
  .

  field-symbols
  : <ls_s__pack>        type ty_s__pack
  , <ls_v__source>      type string
  .

  assign i_r__source to <ls_s__pack>.

  move-corresponding <ls_s__pack> to ld_s__packages2.

  loop at <ls_s__pack>-source
       assigning <ls_v__source>.
    if sy-tabix = 1.
      get time stamp field gd_v__tmstp.
      convert time stamp gd_v__tmstp time zone cs_time_zone  into: time gd_v__time, date gd_v__date.

      concatenate
        `'@ Upload from PC. User `
        sy-uname   `, `
        gd_v__date+0(4) `.`
        gd_v__date+4(2) `.`
        gd_v__date+6(2) ` `
        gd_v__time+0(2) `:`
        gd_v__time+2(2) `:`
        gd_v__time+4(2) `.<BR>`
        into ld_s__instructions2-content.

      find first occurrence of `'@` in section offset 0 of <ls_v__source>.
      if sy-subrc ne 0.
        concatenate ld_s__instructions2-content <ls_v__source> into ld_s__instructions2-content.
      endif.
    else.
      concatenate ld_s__instructions2-content `<BR>` <ls_v__source> into ld_s__instructions2-content.
    endif.
  endloop.

  select single guid
    from ujd_packages2
    into ld_v__guid
    where appset_id   = ld_s__packages2-appset_id
      and app_id      = ld_s__packages2-app_id
      and team_id     = ld_s__packages2-team_id
      and group_id    = ld_s__packages2-group_id
      and package_id  = ld_s__packages2-package_id.

  ld_s__instructions2-appset_id = ld_s__packages2-appset_id.

  if sy-subrc eq 0." если пакет уже существует
    ld_s__instructions2-guid = ld_v__guid.
    if ld_s__instructions2-content is not initial.
      modify ujd_instruction2 from ld_s__instructions2.
    endif.
  else. " если пакета не существует
    cl_uj_services=>generate_guid( importing e_uni_idc32 = ld_v__guid ). " create GUID
    ld_s__packages2-guid      = ld_v__guid.
    ld_s__instructions2-guid  = ld_v__guid.

    modify ujd_packages2    from ld_s__packages2.

    if ld_s__instructions2-content is not initial.
      modify ujd_instruction2 from ld_s__instructions2.
    endif.
  endif.

  if <ls_s__pack>-langu is not initial.
    loop at <ls_s__pack>-langu
         into ld_s__lang.

      ld_s__packagest2-guid         = ld_v__guid.
      ld_s__packagest2-langu        = ld_s__lang-langu.
      ld_s__packagest2-package_desc = ld_s__lang-package_desc.
      ld_s__packagest2-appset_id    = ld_s__packages2-appset_id.

      modify ujd_packagest2 from ld_s__packagest2.
    endloop.
  endif.

endmethod.

method create_object.

  data
  : ld_t__lgfsource  type zvcst_t__lgfsource
  , ld_t__lgfsource1 type zvcst_t__lgfsource
  , ld_v__first_rows type line of zvcst_t__lgfsource
  , ld_v__docname    type uj_docname
  , gd_v__tmstp      type tzntstmpl
  , gd_v__time       type string
  , gd_v__date       type string
  , ld_v__line       type i
  , ld_v__offset     type i
  , ld_v__appset     type uj_appset_id
  .

  field-symbols
  : <ls_s__sclo>     type ty_s__sclo
  .

  assign i_r__source to <ls_s__sclo>.

  get time stamp field gd_v__tmstp.
  convert time stamp gd_v__tmstp time zone cs_time_zone  into: time gd_v__time, date gd_v__date.

  concatenate
    `//@ Upload from PC. User `
    sy-uname   `, `
    gd_v__date+0(4) `.`
    gd_v__date+4(2) `.`
    gd_v__date+6(2) ` `
    gd_v__time+0(2) `:`
    gd_v__time+2(2) `:`
    gd_v__time+4(2) `.`
    into ld_v__first_rows.

  append lines of <ls_s__sclo>-source to ld_t__lgfsource.

  find first occurrence of `//@` in table <ls_s__sclo>-source match line ld_v__line match offset ld_v__offset.
  if ld_v__line = 1 and ld_v__offset = 0.
    modify ld_t__lgfsource index 1 from ld_v__first_rows .
  else.
    append ld_v__first_rows to ld_t__lgfsource1.
    append lines of ld_t__lgfsource to ld_t__lgfsource1.
    ld_t__lgfsource = ld_t__lgfsource1.
  endif.

  ld_v__docname = i_s__tadir-obj_name.

  if cd_v__appset_id is not initial.
    ld_v__appset = cd_v__appset_id.
  else.
    ld_v__appset = i_s__tadir-appset.
  endif.

  call function 'ZFM_PUT_BPC_LGF'
    exporting
      i_appset             = ld_v__appset
      i_application        = i_s__tadir-application
      i_filename           = ld_v__docname
* IMPORTING
*   E_DOC                =
    tables
      lgf                  = ld_t__lgfsource
* EXCEPTIONS
*   NOT_EXISTING         = 1
*   LGF_IS_INITIAL       = 2
*   OTHERS               = 3
            .
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



endmethod.

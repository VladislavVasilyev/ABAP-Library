method COLLECT_DYNPRO.

  data
  : ld_s__dynpro      type ty_s__dynpro
  , ld_s__dynproname  type zcl_vcs_r3tr___dynpro=>ty_s__dynproname
  , ld_t__dynproname  type zcl_vcs_r3tr___dynpro=>ty_t__dynproname.


* Dynpros zu Funktionsgruppen lesen
  data: name type string.
  concatenate cs_sapl area into name.
  select prog dnum from d020s
      into (ld_s__dynproname-progname, ld_s__dynproname-dynnr)
      where prog eq name.
    append ld_s__dynproname to ld_t__dynproname.
  endselect.

* Dynpros selektieren

  loop at ld_t__dynproname into ld_s__dynproname.
    call method zcl_vcs_r3tr___dynpro=>read
      exporting
        i_s__dynproname = ld_s__dynproname
      importing
        e_s__dynpro     = ld_s__dynpro.
    if not ld_s__dynpro is initial.
      append ld_s__dynpro to e_t__dynpro.
    endif.
  endloop.

endmethod.

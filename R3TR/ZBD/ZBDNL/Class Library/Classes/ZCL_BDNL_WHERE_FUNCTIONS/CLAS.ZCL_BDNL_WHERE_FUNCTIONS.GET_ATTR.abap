method get_attr.

  data
  : ld_v__member      type string
  , ld_t__member      type table of string
  , lt_sel            type uj0_t_sel
  , ld_s__sel         type uj0_s_sel
  , lt_member         type uja_t_dim_member
  , lo_security       type ref to cl_uje_check_security
  , lv_user           type uj0_s_user
  , ld_t__param       type zbnlt_t__param
  , ld_v__dimension   type uj_dim_name
  , lr_o__mbr_data    type ref to cl_uja_dim
  , ld_t__attr_list	  type uja_t_attr_name
  , ld_t__sel	        type uj0_t_sel
  , ld_t__hier_list	  type uja_t_hier_name
  , lr_t__std_data    type ref to data
  , ld_v__attr        type uj_attr_name
  .

  field-symbols
  : <ld_t__mbr>          type standard table
  , <ld_s__mbr>          type any
  , <ld_s__comp>         type any
  .

  ld_v__member = i01.
  ld_v__attr   = i02.

  if i03 is supplied.
    ld_v__dimension = i03.
  else.
    ld_v__dimension = dimension.
  endif.

  if appset_id is initial or
     dimension is initial.
    "error
  endif.

  if attribute is not initial.
    "error
  endif.

  append ld_v__attr to ld_t__attr_list.

  condense ld_v__member no-gaps.
  split ld_v__member at `,` into table ld_t__member.

  loop at ld_t__member into ld_v__member.
    ld_v__member = cl_ujk_util=>bas( i_dim_name = dimension i_member = ld_v__member ).
    split ld_v__member at ',' into table ld_t__param.
  endloop.

  ld_s__sel-attribute = uja00_cs_attr-id.
  ld_s__sel-dimension = ld_v__dimension.
  ld_s__sel-sign      = `I`.
  ld_s__sel-option    = `EQ`.

  loop at ld_t__param into ld_s__sel-low.
    append ld_s__sel to ld_t__sel.
  endloop.

  create object lr_o__mbr_data
    exporting
      i_appset_id = appset_id
      i_dimension = ld_v__dimension.

  call method lr_o__mbr_data->read_mbr_data
    exporting
      it_attr_list       = ld_t__attr_list
      it_sel             = ld_t__sel
*          it_sel_mbr         = ld_t__sel_mbr
      it_hier_list       = ld_t__hier_list
*          if_tech_name       = abap_true
      if_only_base       = abap_true
      if_sort            = abap_true
      if_inc_non_display = abap_false
      if_inc_generate    = abap_false
      if_skip_cache      = abap_true
    importing
      er_data            = lr_t__std_data.

  assign lr_t__std_data->* to <ld_t__mbr>.

  loop at <ld_t__mbr> assigning <ld_s__mbr>.
    assign component ld_v__attr of structure <ld_s__mbr> to <ld_s__comp>.
    append  <ld_s__comp> to e.
  endloop.

  sort e.
  delete adjacent duplicates from e.

endmethod.

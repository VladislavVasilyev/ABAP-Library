method READ_SECTIONS.

  data
  : ld_s__section         type line of ty_s__ooclass-sections
  , ls_seo_section_source type zvcst_s__char255
  , lt_seo_section_source type zvcst_t__char255
  .

  do 3 times.
* refresh
    free ld_s__section.

    case sy-index.
      when 1. move seok_limu_public    to ld_s__section-limu.
      when 2. move seok_limu_private   to ld_s__section-limu.
      when 3. move seok_limu_protected to ld_s__section-limu.
    endcase.

    call method zcl_vcs_r3tr___tech=>section_get_source
      exporting
        cifkey  = i_s__clskey
        limu    = ld_s__section-limu
*        state   = 'A'
      importing
        source  = ld_s__section-source
        incname = ld_s__section-incname.

    append ld_s__section to e_t__section.

  enddo.
endmethod.

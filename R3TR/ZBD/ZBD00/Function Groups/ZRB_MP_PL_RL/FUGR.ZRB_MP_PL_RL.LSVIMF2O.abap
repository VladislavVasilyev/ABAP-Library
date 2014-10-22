*---------------------------------------------------------------------*
*       FORM REPLACE                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM replace.
  DATA: firstline_safe TYPE i,
        w_field TYPE vimty_fields_type.

  DESCRIBE TABLE exclude_tab.
  IF sy-tfill GT 0.                    "entries in old exclude_tab
    PERFORM consider_old_exclude_tab TABLES excl_rpl_tab.
  ENDIF.
  CALL FUNCTION 'REPLACE_GET_FIELD'
    EXPORTING
      table                  = x_header-maintview
    IMPORTING
      name_of_selected_field = sel_field_for_replace
    TABLES
      exclude_fields         = excl_rpl_tab
    EXCEPTIONS
      cancelled_by_user      = 0004
      no_valid_fields        = 8.
  CASE sy-subrc.
    WHEN 4.
      function = 'ABR '. EXIT.
    WHEN 8.
      MESSAGE s039(sv) WITH view_name. EXIT.
  ENDCASE.
**************"HCG BC-Set Fix Values Authorithy-Check *****************
  IF vim_bc_chng_allowed = space. "BC-Set Fixvalue change forbidden
    READ TABLE vim_bc_entry_list INTO vim_bc_entry_list_wa                          "#EC CI_SORTSEQ
                                     WITH KEY keys = <vim_xtotal_key>.

    READ TABLE vim_bc_entry_list_wa-fields INTO w_field
                WITH KEY fieldname = sel_field_for_replace.
    IF w_field-flag = vim_profile_fix.
      MESSAGE i184(sv).
    ENDIF.
    CHECK w_field-flag NE vim_profile_fix.
  ENDIF.
***********************************************************************
  LOOP AT x_namtab WHERE viewfield EQ sel_field_for_replace."#EC *
    IF x_header-bastab NE space AND x_header-texttbexst NE space
                                AND x_namtab-texttabfld NE space.
      ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                <vim_ext_txt_struc> TO <replace_field>.
    ELSE.
      ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                <vim_extract_struc> TO <replace_field>.
    ENDIF.
*    ASSIGN extract+x_namtab-position(x_namtab-flength)
*                              TO <replace_field> TYPE x_namtab-inttype.
    IF x_header-bastab NE space AND x_header-texttbexst NE space.
      MOVE x_namtab-texttabfld TO replace_texttable_field.
    ELSE.
      CLEAR replace_texttable_field.
    ENDIF.
  ENDLOOP.
  IF replace_texttable_field EQ space. "view or base table field
    CONCATENATE x_header-maintview sel_field_for_replace
       INTO sel_field_for_replace_l SEPARATED BY '-'.
  ELSE.                                "text table field
    CONCATENATE x_header-texttab sel_field_for_replace
       INTO sel_field_for_replace_l SEPARATED BY '-'.
  ENDIF.
  IF x_header-frm_bf_rpl NE space.
    PERFORM (x_header-frm_bf_rpl) IN PROGRAM (sy-repid).
  ENDIF.
* SET PF-STATUS 'REPLACE'.
  PERFORM set_pf_status USING 'REPLACE'.
  replace_mode = 'X'. vim_special_mode = vim_replace.
  counter = 0.
  firstline_safe = firstline.
  LOOP AT extract.                                          "#EC *
    CHECK <xmark> EQ markiert.
    nextline = exind = sy-tabix.
    IF replace_texttable_field EQ space.  "view or base table field
      CALL FUNCTION 'REPLACE_SET_VALUE'
        EXPORTING
          old_table = <vim_xextract>
        IMPORTING
          new_table = <table1_x>.
      IF x_header-bastab NE space AND x_header-texttbexst NE space.
        <table1_xtext> = <vim_xextract_text>.
      ENDIF.
    ELSE.                              "text table field
      MOVE <vim_extract_struc> TO <table1>.
      CALL FUNCTION 'REPLACE_SET_VALUE'
        EXPORTING
          old_table = <vim_xextract_text>
        IMPORTING
          new_table = <table1_xtext>.
    ENDIF.
    CASE status-type.
      WHEN einstufig.
        CALL SCREEN liste.
      WHEN zweistufig.
        PERFORM process_detail_screen USING 'C'.
        <vim_extract_struc> = <table1>.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
          <vim_xextract_text> = <table1_xtext>.
        ENDIF.
    ENDCASE.
    CHECK ok_code NE 'IGN '.
    IF function EQ 'ABR '.
      EXIT.
    ENDIF.
    counter = counter + 1.
    SUBTRACT 1 FROM mark_extract.
    SUBTRACT 1 FROM mark_total.
  ENDLOOP.
  firstline = nextline = firstline_safe.
  replace_mode = vim_special_mode = space.
  MESSAGE s012(sv) WITH counter.
  IF x_header-frm_af_rpl NE space.
    PERFORM (x_header-frm_af_rpl) IN PROGRAM (sy-repid).
  ENDIF.
ENDFORM.                    "replace

*----------------------------------------------------------------------*
*   INCLUDE LSVIMFX3                                                   *
*----------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form LIST_ALV                                               *
*&--------------------------------------------------------------------*
* D_VIA_SELECTION_SCREEN --> X - mit Selektion, ' ' - Standardliste   *
*&--------------------------------------------------------------------*
FORM list_alv.

*  STATICS: vim_alv_fcat TYPE slis_t_fieldcat_alv,  --> global
*           alv_events TYPE slis_t_event,
*           alv_layout TYPE slis_layout_alv.
  STATICS: texttab_begin LIKE sy-tabix,
           textlen TYPE intlen, unittab TYPE tabname,
           unitname TYPE fieldname, cukytab TYPE tabname,
           cukyname TYPE fieldname,
           glob_unitvalue(3) TYPE c,    "vim_unit,UF296573/2000
           glob_cukyvalue TYPE vim_cuky.
  DATA: textfld_no, textoffset TYPE intlen, rc LIKE sy-subrc,    "#EC NEEDED
        progname LIKE sy-repid, value_len TYPE intlen,           "#EC NEEDED
        w_alv_value_tab TYPE tabl8000.
  FIELD-SYMBOLS: <alv_fcat> LIKE LINE OF vim_alv_fcat,
                 <textfields>.                              "#EC *

  IF x_header-frm_bf_prn <> space.
* old user exit for printing still used
    PERFORM drucken_ztp_alt.
    EXIT.
  ENDIF.
  IF NOT vim_alv_fcat[] IS INITIAL.
    READ TABLE vim_alv_fcat ASSIGNING <alv_fcat> INDEX 1.
    IF <alv_fcat>-ref_tabname <> view_name.
      UNASSIGN <alv_fcat>. FREE vim_alv_fcat.
    ENDIF.
  ENDIF.
  IF vim_alv_fcat[] IS INITIAL.
* build up field catalogue from X_NAMTAB
    PERFORM fill_alv_fieldcat CHANGING vim_alv_fcat
                                       texttab_begin
                                       vim_alv_value_length
                                       unittab
                                       unitname
                                       glob_unitvalue
                                       cukytab
                                       cukyname
                                       glob_cukyvalue.
    PERFORM define_alv_callbacks CHANGING vim_alv_events.
    PERFORM make_list_commentary USING unittab
                                       unitname
                                       glob_unitvalue
                                       cukytab
                                       cukyname
                                       glob_cukyvalue
                                 CHANGING vim_list_header.
    PERFORM make_alv_layout CHANGING vim_alv_layout
                                     vim_alv_print.
    PERFORM init_alv_variant CHANGING vim_var_save
                                      vim_var_default
                                      vim_alv_variant.
    vim_alv_called_by = 'VIM_CALL_ALV'.
*    REFRESH: vim_alv_excluding, vim_alv_special_groups,
*             vim_alv_sort, vim_alv_event_exit.
*    CLEAR:   vim_alv_print, vim_alv_sel_hide.
  ENDIF.                               "new structure table
  REFRESH alv_value_tab.
  IF status-mode = list_bild.
* Build ALV_VALUE_TAB
    LOOP AT extract.
      w_alv_value_tab = <vim_xextract>.
*    LOOP AT extract ASSIGNING <extract_line>.
*      alv_value_tab = <extract_line>.
      APPEND w_alv_value_tab TO alv_value_tab.
    ENDLOOP.
  ELSE.
* Build VALUE_TAB with single line
    w_alv_value_tab = <vim_xextract>.
*    alv_value_tab = extract.
    APPEND w_alv_value_tab TO alv_value_tab.
  ENDIF.
  IF x_header-bastab <> space AND x_header-texttbexst <> space.
* table and texttable
    textlen = x_header-aft_txttbc - x_header-aft_txtkc.
*  IF x_header-bastab = space OR x_header-texttbexst = space
*   OR x_header-maintview NE x_header-viewname.
* no table & texttable
*    CLEAR textlen.
*  ENDIF.
*  IF textlen <> 0.
* Shift fields
    PERFORM maintain_alv_value_tab_text USING    textlen.
  ELSE.
    vim_alv_value_length = x_header-tablen.
  ENDIF.
  IF x_header-frm_bf_alv <> space.
    PERFORM (x_header-frm_bf_alv) IN PROGRAM (sy-repid).
* Release 6.10(Unicode): alv_value_tab has got type RAW!
* useful parameters:
*   vim_alv_value_length     int. length of dataset in alv_value_tab
*   vim_alv_called_by        form routine calling FM ALV_LIST_DISPLAY
*                            preset value: 'VIM_CALL_ALV'
*   alv_value_tab[]          internal table containing values
*   vim_alv_fcat[]     \
*   vim_alv_events[]    |
*   vim_list_header[]   >    preset by view-maintenance
*   vim_alv_variant     |
*   vim_alv_layout     /
    CHECK NOT alv_value_tab[] IS INITIAL. "suppress list
  ENDIF.
  PERFORM check_list_before_alv CHANGING rc.
  CHECK rc = 0.
  progname = sy-repid.
  CALL FUNCTION 'REUSE_ALV_TABLE_CREATE'
    EXPORTING
      it_fieldcat        = vim_alv_fcat
      i_callback_program = progname
      i_formname         = vim_alv_called_by.
  FREE alv_value_tab.
ENDFORM.                               " LIST_ALV

*&--------------------------------------------------------------------*
*&      Form DRUCKEN_ZTP_ALT                                          *
*&--------------------------------------------------------------------*
* Keeps compatibility of view maintenance dialogs using old user exit
* "before printing"
* D_VIA_SELECTION_SCREEN --> X - mit Selektion, ' ' - Standardliste   *
*&--------------------------------------------------------------------*
FORM drucken_ztp_alt.
  DATA: rc_safe LIKE sy-subrc, texttab_begin LIKE sy-tabix, x TYPE i, "#EC NEEDED
        entifct_begin LIKE sy-tabix, len TYPE i,
        after_text_assigned TYPE c, hname LIKE d021s-fnam. "#EC NEEDED
  DATA: fcat_entry TYPE slis_fieldcat_alv, i TYPE i, "#EC NEEDED
        cukytab TYPE tabname, unittab TYPE tabname, rc LIKE sy-subrc,
        cukyname TYPE fieldname, unitname TYPE fieldname,
        cukyvalue TYPE vim_cuky, unitvalue TYPE vim_unit,
        length TYPE doffset, cukylength TYPE doffset,
        fcat_entry2 TYPE slis_fieldcat_alv, progname LIKE sy-repid, "#EC NEEDED
        alv_called_by TYPE char30 VALUE 'VIM_CALL_ALV'.
  FIELD-SYMBOLS: <before_text>, <text>, <after_text>,       "#EC *
                 <cuky>, <unit>,
                 <value> TYPE tabl8000, <w_value_tab_x> TYPE x.

  CLEAR structure_table.
  DESCRIBE TABLE structure_table.
  IF sy-tfill NE 0. READ TABLE structure_table INDEX 1. ENDIF.
  IF structure_table-tabname NE view_name.
    CALL FUNCTION 'VIEW_GET_FIELDTAB'
      EXPORTING
        view_name = view_name
      TABLES
        fieldtab  = structure_table.
    IF x_header-bastab NE space AND x_header-texttbexst NE space
       AND x_header-maintview = x_header-viewname.           "Subviews
* einfügen text-felder in structure_table hinter entity-key
      LOOP AT x_namtab WHERE texttabfld NE space
                         AND keyflag NE space.
        texttab_begin = sy-tabix.
        EXIT.
      ENDLOOP.
      LOOP AT x_namtab WHERE texttabfld EQ space
                         AND keyflag EQ space.
        entifct_begin = sy-tabix.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.  "no entifct fields -> delete text key fields
        LOOP AT structure_table FROM texttab_begin
                                WHERE keyflag NE space.
          DELETE structure_table.
        ENDLOOP.
      ELSE.
        WHILE sy-subrc EQ 0.
          LOOP AT structure_table FROM texttab_begin.
            DELETE structure_table.
            IF structure_table-keyflag EQ space.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF sy-subrc EQ 0.
            INSERT structure_table INDEX entifct_begin.
            ADD: 1 TO entifct_begin, 1 TO texttab_begin.
          ENDIF.
        ENDWHILE.
      ENDIF.
* aktualisieren von offset und position in structure_table
      len = 0.
      LOOP AT structure_table.
        structure_table-offset = len.
        structure_table-position = sy-tabix.
* Alignment
        IF 'CNDT' CS structure_table-inttype.
* Character-like datatypes
          x = ( structure_table-offset
                + cl_abap_char_utilities=>charsize )
                MOD cl_abap_char_utilities=>charsize.
          IF x NE 0.
            structure_table-offset = structure_table-offset
                               + cl_abap_char_utilities=>charsize - x.
          ENDIF.
        ELSE.
          CASE structure_table-datatype.
            WHEN 'INT2' OR 'PREC'.
              x = ( structure_table-offset + 2 ) MOD 2.
              IF x NE 0.
                structure_table-offset = structure_table-offset + 2 - x.
              ENDIF.
            WHEN 'INT4'.
              x = ( structure_table-offset + 4 ) MOD 4.
              IF x NE 0.
                structure_table-offset = structure_table-offset + 4 - x.
              ENDIF.
            WHEN 'FLTP'.
              x = ( structure_table-offset + 8 ) MOD 8.
              IF x NE 0.
                structure_table-offset = structure_table-offset + 8 - x.
              ENDIF.
          ENDCASE.
        ENDIF.
        MODIFY structure_table.
        len = structure_table-offset + structure_table-intlen.
      ENDLOOP.
    ENDIF.                             "table with texttable
    IF x_header-hiddenflag NE space.   "hidden fields exist
* ignore hidden fields
      LOOP AT x_namtab WHERE readonly EQ vim_hidden OR
       domname IN vim_guid_domain.
        LOOP AT structure_table WHERE fieldname EQ x_namtab-viewfield.
          DELETE structure_table.
          EXIT.
        ENDLOOP.
      ENDLOOP.
* aktualisieren von offset und position in structure_table
      len = 0.
      LOOP AT structure_table.
        structure_table-offset = len.
        structure_table-position = sy-tabix.
        IF 'CNDT' CS structure_table-inttype.
* Character-like datatypes
          x = ( structure_table-offset
                + cl_abap_char_utilities=>charsize )
                MOD cl_abap_char_utilities=>charsize.
          IF x NE 0.
            structure_table-offset = structure_table-offset
                               + cl_abap_char_utilities=>charsize - x.
          ENDIF.
        ELSE.
          CASE structure_table-datatype.
            WHEN 'INT2' OR 'PREC'.
              x = ( structure_table-offset + 2 ) MOD 2.
              IF x NE 0.
                structure_table-offset = structure_table-offset + 2 - x.
              ENDIF.
            WHEN 'INT4'.
              x = ( structure_table-offset + 4 ) MOD 4.
              IF x NE 0.
                structure_table-offset = structure_table-offset + 4 - x.
              ENDIF.
            WHEN 'FLTP'.
              x = ( structure_table-offset + 8 ) MOD 8.
              IF x NE 0.
                structure_table-offset = structure_table-offset + 8 - x.
              ENDIF.
          ENDCASE.
        ENDIF.
        MODIFY structure_table.
        len = structure_table-offset + structure_table-intlen.
      ENDLOOP.
    ENDIF.                             "hidden fields exist
  ENDIF.                               "new structure table
* Aufbau der Value_tab
  ASSIGN value_tab TO <w_value_tab_x> CASTING.
  IF x_header-bastab NE space AND x_header-texttbexst NE space
                                       "base table with text table
     AND x_header-maintview = x_header-viewname.
    CLEAR value_tab.
    IF status-mode EQ list_bild.
      LOOP AT extract.
        PERFORM build_valtab_hfields.
      ENDLOOP.
    ELSE.
      PERFORM build_valtab_hfields.
    ENDIF.
*    ENDIF.
  ELSE.
* view or base table without text table and user exits exists or hidden
* fields exist
    CLEAR value_tab.
    IF x_header-hiddenflag EQ space AND"no hidden fields
       x_header-fieldorder EQ space.   "Subviews /untersch. Feldreihenf.
      IF status-mode EQ list_bild.
        LOOP AT extract.
          MOVE <vim_xextract> TO <w_value_tab_x>(x_header-tablen).
*          MOVE extract TO value_tab(tablen).
          APPEND value_tab.
        ENDLOOP.
      ELSE.
        MOVE <vim_xextract> TO <w_value_tab_x>(x_header-tablen).
*        MOVE extract TO value_tab(tablen).
        APPEND value_tab.
      ENDIF.
    ELSE. "hidden fields exist -> move field by field
      IF status-mode EQ list_bild.
        LOOP AT extract.
          PERFORM build_valtab_hfields.
        ENDLOOP.
      ELSE.
        PERFORM build_valtab_hfields.
      ENDIF.
    ENDIF.
  ENDIF.                               "base table with text_table.
  IF x_header-frm_bf_prn NE space.     "user exit exists
* perform user exit
    PERFORM (x_header-frm_bf_prn) IN PROGRAM (sy-repid).
  ENDIF.
  CHECK NOT value_tab[] IS INITIAL.    "suppress list
************************************************************************
* Build up ALV fieldcatalogue from STRUCTURE
  REFRESH vim_alv_fcat.
  LOOP AT structure_table.
    CLEAR fcat_entry.
    PERFORM conv_dfies_fcat USING structure_table
                                  sy-tabix
                            CHANGING fcat_entry.
    APPEND fcat_entry TO vim_alv_fcat.
  ENDLOOP.
  length = structure_table-offset + structure_table-intlen.
* consider CUKY or UNIT fields.......
  DESCRIBE TABLE vim_alv_fcat LINES i.
  LOOP AT vim_alv_fcat INTO fcat_entry WHERE datatype = 'CURR'
   OR datatype = 'QUAN'.
    CASE fcat_entry-datatype.
      WHEN 'CURR'.
        READ TABLE x_namtab WITH KEY viewfield = fcat_entry-cfieldname
            TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
* try to get global currency field
          READ TABLE x_namtab WITH KEY viewfield = fcat_entry-fieldname.
          cukytab = x_namtab-reftable.
          cukyname = x_namtab-reffield.
          CONCATENATE x_namtab-reftable '-' x_namtab-reffield
                  INTO hname.
          ASSIGN (hname) TO <cuky>.
          IF sy-subrc = 0.
* global currency key exists to be inserted in value table
            fcat_entry-currency = cukyvalue = <cuky>.
          ENDIF.
        ENDIF.
      WHEN 'QUAN'.
        READ TABLE x_namtab WITH KEY viewfield = fcat_entry-qfieldname
            TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
* try to get global quantity field
          READ TABLE x_namtab WITH KEY viewfield = fcat_entry-fieldname.
          unittab = x_namtab-reftable.
          unitname = x_namtab-reffield.
          CONCATENATE x_namtab-reftable '-' x_namtab-reffield
                  INTO hname.
          ASSIGN (hname) TO <unit>.
          IF sy-subrc = 0.
* global unit key exists to be inserted in value table
            fcat_entry-quantity = unitvalue = <unit>.
          ENDIF.
        ENDIF.
    ENDCASE.
    MODIFY vim_alv_fcat FROM fcat_entry.
  ENDLOOP.
  REFRESH alv_value_tab.
  LOOP AT value_tab.
    APPEND <w_value_tab_x> TO alv_value_tab.
  ENDLOOP.
*  APPEND LINES OF value_tab TO alv_value_tab.
  FREE value_tab.
  IF NOT cukyname IS INITIAL.
* Append global currency to value_tab
    LOOP AT alv_value_tab ASSIGNING <value>.
      <value>+length = cukyvalue.
    ENDLOOP.
    length = length + cukylength.
  ENDIF.
  IF NOT unitname IS INITIAL.
* Append global unit to value_tab
    LOOP AT alv_value_tab ASSIGNING <value>.
      <value>+length = unitvalue.
    ENDLOOP.
  ENDIF.
  PERFORM define_alv_callbacks CHANGING vim_alv_events.
  PERFORM make_list_commentary USING unittab
                                     unitname
                                     unitvalue
                                     cukytab
                                     cukyname
                                     cukyvalue
                               CHANGING vim_list_header.
  PERFORM make_alv_layout CHANGING vim_alv_layout
                                   vim_alv_print.
  PERFORM init_alv_variant CHANGING vim_var_save
                                    vim_var_default
                                    vim_alv_variant.
  progname = sy-repid.
  PERFORM check_list_before_alv CHANGING rc.
  CHECK rc = 0.
  CALL FUNCTION 'REUSE_ALV_TABLE_CREATE'
    EXPORTING
      it_fieldcat        = vim_alv_fcat
      i_callback_program = progname
      i_formname         = alv_called_by.
  FREE alv_value_tab.
*  if sy-subrc ne 0. raise print_error. endif.
ENDFORM.                               " DRUCKEN_ZTP_ALT

*&---------------------------------------------------------------------*
*&      Form  MAKE_LIST_COMMENTARY
*&---------------------------------------------------------------------*
*       Build up list header
*----------------------------------------------------------------------*
*      <--P_LIST_COMMENTARY  text
*----------------------------------------------------------------------*
FORM make_list_commentary USING p_unittab TYPE tabname
                                p_unitname TYPE fieldname
                                p_unitvalue TYPE any
                                                "vim_unitUF296573/2000
                                p_cukytab TYPE tabname
                                p_cukyname TYPE fieldname
                                p_cukyvalue TYPE vim_cuky
                       CHANGING p_list_header TYPE slis_t_listheader.
  DATA: h_header TYPE slis_listheader,
        text(40), w_dfies TYPE dfies.                        "#EC NEEDED

  REFRESH p_list_header.
  h_header-typ = 'H'.
  h_header-info = x_header-ddtext.
  APPEND h_header TO p_list_header.
  h_header-typ = 'S'.
  IF x_header-bastab NE space AND x_header-texttbexst NE space
   AND x_header-maintview = x_header-viewname.
    h_header-key = svim_text_p01.
  ELSE.
    h_header-key = svim_text_p02.
  ENDIF.
  h_header-info = x_header-viewname.
  APPEND h_header TO p_list_header.
  IF x_header-clidep <> space.
    h_header-key = svim_text_p03.
    h_header-info = sy-mandt.
    APPEND h_header TO p_list_header.
  ENDIF.
  IF p_unitname <> space.
    CLEAR h_header.
    h_header-typ = 'S'.
    PERFORM vim_get_reffield_alv USING p_unitname
                                       p_unittab
                                  CHANGING w_dfies.
    IF w_dfies <> space.
      IF w_dfies-scrtext_m <> space.
        h_header-key = w_dfies-scrtext_m(20).
      ELSE.
        IF w_dfies-scrtext_l <> space.
          h_header-key = w_dfies-scrtext_l(20).
        ELSE.
          IF w_dfies-scrtext_s <> space.
            h_header-key = w_dfies-scrtext_s(10).
          ELSE.
            IF w_dfies-reptext <> space.
              h_header-key = w_dfies-reptext(20).
            ELSE.
              h_header-key = w_dfies-fieldname.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    h_header-info = p_unitvalue.
    APPEND h_header TO p_list_header.
  ENDIF.
  IF p_cukyname <> space.
    CLEAR h_header.
    h_header-typ = 'S'.
    PERFORM vim_get_reffield_alv USING p_cukyname
                                       p_cukytab
                                  CHANGING w_dfies.
    IF w_dfies <> space.
      IF w_dfies-scrtext_m <> space.
        h_header-key = w_dfies-scrtext_m(20).
      ELSE.
        IF w_dfies-scrtext_l <> space.
          h_header-key = w_dfies-scrtext_l(20).
        ELSE.
          IF w_dfies-scrtext_s <> space.
            h_header-key = w_dfies-scrtext_s(10).
          ELSE.
            IF w_dfies-reptext <> space.
              h_header-key = w_dfies-reptext(20).
            ELSE.
              h_header-key = w_dfies-fieldname.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    h_header-info = p_cukyvalue.
    APPEND h_header TO p_list_header.
  ENDIF.
ENDFORM.                               " MAKE_LIST_COMMENTARY
*&---------------------------------------------------------------------*
*&      Form  DEFINE_ALV_CALLBACKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ALV_EVENTS  text
*----------------------------------------------------------------------*
FORM define_alv_callbacks CHANGING p_alv_events TYPE slis_t_event.
  DATA: h_event TYPE slis_alv_event.
  CONSTANTS: formname_top_of_list TYPE slis_formname
             VALUE 'ALV_TOP_OF_LIST',
             formname_top_of_page TYPE slis_formname
             VALUE 'ALV_TOP_OF_PAGE',
             formname_end_of_page TYPE slis_formname
             VALUE 'ALV_END_OF_PAGE',
             formname_end_of_list TYPE slis_formname
             VALUE 'ALV_END_OF_LIST'.
  REFRESH p_alv_events.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_alv_events.
* define TOP_OF_LIST event
  READ TABLE p_alv_events WITH KEY name = slis_ev_top_of_list
                           INTO h_event.
  IF sy-subrc = 0.
    h_event-form = formname_top_of_list.
    APPEND h_event TO p_alv_events.
  ENDIF.
* define TOP_OF_PAGE event
  READ TABLE p_alv_events WITH KEY name = slis_ev_top_of_page
                           INTO h_event.
  IF sy-subrc = 0.
    h_event-form = formname_top_of_page.
    APPEND h_event TO p_alv_events.
  ENDIF.
* define END_OF_PAGE event
  READ TABLE p_alv_events WITH KEY name = slis_ev_end_of_page
                           INTO h_event.
  IF sy-subrc = 0.
    h_event-form = formname_end_of_page.
    APPEND h_event TO p_alv_events.
  ENDIF.
* define END_OF_LIST event
  READ TABLE p_alv_events WITH KEY name = slis_ev_end_of_list
                           INTO h_event.
  IF sy-subrc = 0.
    h_event-form = formname_end_of_list.
    APPEND h_event TO p_alv_events.
  ENDIF.
ENDFORM.                    "define_alv_callbacks

*&---------------------------------------------------------------------*
*&      Form  ALV_TOP_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_top_of_list.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = vim_list_header.

ENDFORM.                               " ALV_TOP_OF_LIST
*&---------------------------------------------------------------------*
*&      Form  ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_top_of_page.
  WRITE AT (sy-linsz) sy-datum RIGHT-JUSTIFIED.
ENDFORM.                               " ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  ALV_END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_end_of_page.
  WRITE AT (sy-linsz) sy-pagno CENTERED.
ENDFORM.                               " ALV_END_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  MAKE_ALV_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_ALV_LAYOUT  text
*----------------------------------------------------------------------*
FORM make_alv_layout CHANGING p_alv_layout TYPE slis_layout_alv
                              p_alv_print  TYPE slis_print_alv.
* screen layout
  CLEAR p_alv_layout.
  p_alv_layout-colwidth_optimize = 'X'.
  p_alv_layout-f2code = '&ETA'.
  p_alv_layout-detail_popup = 'X'.
* print layout
  p_alv_print-reserve_lines = 2.                            "GKPR/1014972
  p_alv_print-no_print_listinfos = 'X'.
ENDFORM.                               " MAKE_ALV_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  FILL_ALV_FIELDCAT
*&---------------------------------------------------------------------*
*       Builds up ALV-fieldcatalogue from X_NAMTAB
*----------------------------------------------------------------------*
*      <--P_VIM_ALV_FCAT  ALV-fieldctalogue
*----------------------------------------------------------------------*
FORM fill_alv_fieldcat CHANGING p_vim_alv_fcat TYPE slis_t_fieldcat_alv
                                texttab_begin LIKE sy-tabix
                                p_value_length TYPE intlen
*                                p_textlen TYPE intlen
                                p_unittab TYPE tabname
                                p_unitname TYPE fieldname
                                p_unitvalue TYPE any "vim_unit
                                       "UF296573/2000
                                p_cukytab TYPE tabname
                                p_cukyname TYPE fieldname
                                p_cukyvalue TYPE vim_cuky.

  DATA: fcat_header TYPE slis_fieldcat_alv, textfld_no TYPE i,
        fcat_reffield TYPE slis_fieldcat_alv, rc LIKE sy-subrc,  "#EC NEEDED
        first TYPE xfeld VALUE 'X', list_width TYPE outputlen,
        i TYPE i, first_func_field TYPE i, text_outp_len TYPE outputlen,
        fldno(2) TYPE n, strln TYPE i,
        hname TYPE fnam_____4, maintview, global_unit_set,  "#EC *
        global_cuky_set.                                       "#EC NEEDED

  CONSTANTS: max_list_width TYPE i VALUE 250.

  FIELD-SYMBOLS: <alv_fcat> LIKE LINE OF p_vim_alv_fcat,
                 <alv_fcat2> LIKE LINE OF p_vim_alv_fcat, "UF412290/2001
                 <x_namt> LIKE LINE OF x_namtab, <cuky> TYPE vim_cuky,
                 <unit> TYPE ANY.      "vim_unit. UF296573/2000

  REFRESH p_vim_alv_fcat.
  CLEAR:  p_unitname, p_cukyname, p_unitvalue, p_cukyvalue,
          p_value_length.
  IF x_header-bastab EQ space OR x_header-texttbexst EQ space
   OR x_header-maintview NE x_header-viewname.
    maintview = 'X'.                   "It's a maintenance view!
  ENDIF.
* Build up field catalogue
  LOOP AT x_namtab ASSIGNING <x_namt> WHERE texttabfld = space
   OR keyflag = space.
    i = i + 1.
    fcat_header-col_pos = i.
    fcat_header-fieldname = <x_namt>-viewfield.
    IF maintview = space.
      fcat_header-ref_tabname = <x_namt>-bastabname.
    ELSE.
      fcat_header-ref_tabname = x_header-maintview.
    ENDIF.
    fcat_header-key = <x_namt>-keyflag.
    fcat_header-seltext_l = <x_namt>-scrtext_l.
    fcat_header-seltext_m = <x_namt>-scrtext_m.
    fcat_header-seltext_s = <x_namt>-scrtext_s.
    fcat_header-reptext_ddic = <x_namt>-reptext.
    fcat_header-datatype = <x_namt>-datatype.
    fcat_header-inttype = <x_namt>-inttype.
    fcat_header-ddic_outputlen = <x_namt>-outputlen.
    fcat_header-intlen = <x_namt>-flength.
    fcat_header-lowercase = <x_namt>-lowercase.
    CASE <x_namt>-datatype.
      WHEN 'CLNT'.
        IF x_header-clidep <> space.
          fcat_header-tech = 'X'.
        ENDIF.
      WHEN 'CURR'.
        READ TABLE x_namtab WITH KEY viewfield = <x_namt>-reffield
            TRANSPORTING NO FIELDS.
        IF sy-subrc = 0 AND <x_namt>-reftable = x_header-maintview.
          "UF163276/2001
* currency field in structure
          fcat_header-cfieldname = <x_namt>-reffield.
        ELSE.
          IF p_cukyvalue IS INITIAL.
* try to get global currency field
            p_cukytab = <x_namt>-reftable.
            p_cukyname = <x_namt>-reffield.
            CONCATENATE <x_namt>-reftable '-' <x_namt>-reffield
                    INTO hname.
            ASSIGN (hname) TO <cuky>.
            IF sy-subrc = 0.
* global currency key exists to be inserted in value table
              fcat_header-currency = p_cukyvalue = <cuky>.
            ENDIF.
          ELSE.
            fcat_header-currency = p_cukyvalue.
          ENDIF.
        ENDIF.
      WHEN 'QUAN'.
        READ TABLE x_namtab WITH KEY viewfield = <x_namt>-reffield
            TRANSPORTING NO FIELDS.
        IF sy-subrc = 0 AND <x_namt>-reftable = x_header-maintview.
          "UF163276/2001.
* quantity field in structure
          fcat_header-qfieldname = <x_namt>-reffield.
        ELSE.
* try to get global quantity field
          IF p_unitvalue IS INITIAL.
            p_unittab = <x_namt>-reftable.
            p_unitname = <x_namt>-reffield.
            CONCATENATE <x_namt>-reftable '-' <x_namt>-reffield
                    INTO hname.
            ASSIGN (hname) TO <unit>.
            IF sy-subrc = 0.
* global unit key exists to be inserted in value table
              fcat_header-quantity = p_unitvalue = <unit>.
            ENDIF.
          ELSE.
            fcat_header-quantity = p_unitvalue.
          ENDIF.
        ENDIF.
    ENDCASE.
    IF <x_namt>-readonly = vim_hidden
* hide hidden fields
     OR <x_namt>-domname IN vim_guid_domain.
* no GUID-values
      fcat_header-tech = 'X'.
    ELSE.
      list_width = list_width + <x_namt>-outputlen + 1.
    ENDIF.
    p_value_length = p_value_length + fcat_header-intlen.
    APPEND fcat_header TO p_vim_alv_fcat.
    CLEAR fcat_header.
    CHECK <x_namt>-texttabfld <> space.
    textfld_no = textfld_no + 1.       "get no. of text fields
*    p_textlen = p_textlen + <x_namt>-flength. "int. length of text flds
    CHECK <x_namt>-readonly <> vim_hidden.
    IF first <> space.
      texttab_begin = i.               "position of 1st text fld
      CLEAR first.
    ENDIF.
    text_outp_len = text_outp_len + <x_namt>-outputlen.
  ENDLOOP.
  first = 'X'.
  CLEAR i.
  IF x_header-bastab NE space AND x_header-texttbexst NE space
   AND x_header-maintview = x_header-viewname.
* Place text fields behind key fields.
    LOOP AT p_vim_alv_fcat ASSIGNING <alv_fcat> WHERE key = space.
      IF first <> space.
        first_func_field = <alv_fcat>-col_pos.
        CLEAR first.
      ENDIF.
      IF sy-tabix < texttab_begin.
        <alv_fcat>-col_pos = <alv_fcat>-col_pos + textfld_no.
      ELSE.
        i = i + 1.
        <alv_fcat>-col_pos = first_func_field + i - 1.
      ENDIF.
    ENDLOOP.
    first = 'X'.
    SORT p_vim_alv_fcat BY col_pos.
  ENDIF.
  IF list_width > max_list_width.
* line size to large for one line
    list_width = i = 1.
    LOOP AT p_vim_alv_fcat ASSIGNING <alv_fcat>.
      list_width = list_width + <alv_fcat>-ddic_outputlen + 1.
      IF list_width > max_list_width.
        i = i + 1.
        list_width = <alv_fcat>-ddic_outputlen + 1.
      ENDIF.
      <alv_fcat>-row_pos = i.
    ENDLOOP.
  ENDIF.
  IF maintview = space.                  "UF412290/2001b
*check field catalogue for doublettes and change their fieldname
    LOOP AT p_vim_alv_fcat ASSIGNING <alv_fcat>.
      i = sy-tabix.
      CLEAR fldno.
      LOOP AT p_vim_alv_fcat ASSIGNING <alv_fcat2>
       WHERE fieldname = <alv_fcat>-fieldname.
        CHECK sy-tabix <> i.
        <alv_fcat2>-ref_fieldname = <alv_fcat2>-fieldname.
        ADD 1 TO fldno.
        CONCATENATE <alv_fcat2>-fieldname fldno
         INTO <alv_fcat2>-fieldname.
        IF sy-subrc <> 0.
          strln = strlen( <alv_fcat2>-fieldname ) - 2.
          CONCATENATE <alv_fcat2>-fieldname(strln) fldno
          INTO <alv_fcat2>-fieldname.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.                                 "UF412290/2001e
ENDFORM.                               " FILL_ALV_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  VIM_CALL_ALV
*&---------------------------------------------------------------------*
*       Calls ABAP List Viewer. Has to be called from Function Module
*       REUSE_ALV_TABLE_CREATE.
*----------------------------------------------------------------------*
*      -->VALUE_TAB
*----------------------------------------------------------------------*
FORM vim_call_alv TABLES value_tab.

  DATA: progname LIKE sy-repid.
  FIELD-SYMBOLS: <alv_value_tab_x> TYPE tabl8000,
                 <value_tab_x> TYPE x.

  REFRESH value_tab.
  ASSIGN value_tab TO <value_tab_x> CASTING.
  LOOP AT alv_value_tab ASSIGNING <alv_value_tab_x>.
    <value_tab_x> = <alv_value_tab_x>.
    APPEND value_tab.
  ENDLOOP.
*  APPEND LINES OF alv_value_tab TO value_tab.
  progname = sy-repid.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
           i_callback_program       = progname
           is_layout                = vim_alv_layout
           it_fieldcat              = vim_alv_fcat
*           it_excluding             = vim_alv_excluding
*           it_special_groups        = vim_alv_special_groups
*           it_sort                  = vim_alv_sort
*            IT_FILTER                =
*           is_sel_hide              = vim_alv_sel_hide
           i_default                = vim_var_default
           i_save                   = vim_var_save
           is_variant               = vim_alv_variant
           it_events                = vim_alv_events
*           it_event_exit            = vim_alv_event_exit
           is_print                 = vim_alv_print
*            IS_REPREP_ID             =
*            I_SCREEN_START_COLUMN    = 0
*            I_SCREEN_START_LINE      = 0
*            I_SCREEN_END_COLUMN      = 0
*            I_SCREEN_END_LINE        = 0
*       IMPORTING
*            E_EXIT_CAUSED_BY_CALLER  =
*            ES_EXIT_CAUSED_BY_USER   =
       TABLES
            t_outtab                 = value_tab[]
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.
  IF sy-subrc NE 0. RAISE print_error. ENDIF.               "#EC *
ENDFORM.                               "vim_call_alv
*&---------------------------------------------------------------------*
*&      Form  MAINTAIN_ALV_VALUE_TAB_TEXT
*&---------------------------------------------------------------------*
*       shift textfield directly behind key
*----------------------------------------------------------------------*
*      -->P_TEXTLEN  text
*----------------------------------------------------------------------*
FORM maintain_alv_value_tab_text USING    p_textlen TYPE intlen.

  DATA: x TYPE i, record TYPE tabl8000, textoffset TYPE intlen,
        BEGIN OF new_offs,
          ref_tabname TYPE tabname,
          fieldname TYPE viewfield,
          ref_fieldname TYPE fieldname,
          offset TYPE tabfdpos,
        END OF new_offs.

  STATICS: t_fld_offs LIKE SORTED TABLE OF new_offs WITH UNIQUE KEY
                           ref_tabname fieldname ref_fieldname
                           INITIAL SIZE 1,
           viewname TYPE viewname.
  FIELD-SYMBOLS: <x_namt> LIKE LINE OF x_namtab,
                 <alv_fcat> TYPE slis_fieldcat_alv,
                 <alv_val>.

  IF viewname <> x_header-viewname.
    viewname = x_header-viewname.
    REFRESH t_fld_offs.
    new_offs-offset = x_header-after_keyc.
*    new_offs-offset = x_header-keylen.
* Offset aktualisieren
    LOOP AT vim_alv_fcat ASSIGNING <alv_fcat> WHERE key = space.
      new_offs-ref_tabname = <alv_fcat>-ref_tabname.
      new_offs-fieldname = <alv_fcat>-fieldname.
      new_offs-ref_fieldname = <alv_fcat>-ref_fieldname. "UF412290/2001
* Alignment
      IF 'CNDT' CS <alv_fcat>-inttype.
* Character-like datatypes
        x = ( new_offs-offset + cl_abap_char_utilities=>charsize )
              MOD cl_abap_char_utilities=>charsize.
        IF x NE 0.
          new_offs-offset = new_offs-offset
                             + cl_abap_char_utilities=>charsize - x.
        ENDIF.
      ELSE.
        CASE <alv_fcat>-datatype.
          WHEN 'INT2' OR 'PREC'.
            x = ( new_offs-offset + 2 ) MOD 2.
            IF x NE 0.
              new_offs-offset = new_offs-offset + 2 - x.
            ENDIF.
          WHEN 'INT4'.
            x = ( new_offs-offset + 4 ) MOD 4.
            IF x NE 0.
              new_offs-offset = new_offs-offset + 4 - x.
            ENDIF.
          WHEN 'FLTP'.
            x = ( new_offs-offset + 8 ) MOD 8.
            IF x NE 0.
              new_offs-offset = new_offs-offset + 8 - x.
            ENDIF.
        ENDCASE.
      ENDIF.
      INSERT new_offs INTO TABLE t_fld_offs.
      new_offs-offset = new_offs-offset + <alv_fcat>-intlen.
    ENDLOOP.
  ENDIF.
  textoffset = x_header-after_tabc + x_header-aft_txtkc.
*  textoffset = x_header-tablen + x_header-textkeylen.
  LOOP AT alv_value_tab ASSIGNING <alv_val>.
    record(x_header-after_keyc) = <alv_val>(x_header-after_keyc).
*    record = <alv_val>(x_header-keylen).
    IF p_textlen > 0.
      record+x_header-after_keyc(p_textlen) =
       <alv_val>+textoffset(p_textlen).
*      record+x_header-keylen(p_textlen) =
*       <alv_val>+textoffset(p_textlen).
    ENDIF.
    LOOP AT x_namtab ASSIGNING <x_namt> WHERE keyflag = space AND
                                              texttabfld = space.
      READ TABLE t_fld_offs INTO new_offs WITH TABLE KEY
                                    ref_tabname = <x_namt>-bastabname
                                    fieldname = <x_namt>-viewfield
                                    ref_fieldname = space.
      IF sy-subrc = 0.
        record+new_offs-offset(<x_namt>-flength) =
         <alv_val>+<x_namt>-position(<x_namt>-flength).
      ELSE.                                "UF412290/2001b
* field had to be renamed because of doublettes
        READ TABLE t_fld_offs INTO new_offs WITH KEY
                                    ref_tabname = <x_namt>-bastabname
                                    ref_fieldname = <x_namt>-viewfield.
        IF sy-subrc = 0.
          record+new_offs-offset(<x_namt>-flength) =
           <alv_val>+<x_namt>-position(<x_namt>-flength).
        ENDIF.                             "UF412290/2001e
      ENDIF.
    ENDLOOP.
    CLEAR <alv_val>.
    <alv_val> = record.
  ENDLOOP.
ENDFORM.                               " MAINTAIN_ALV_VALUE_TAB_TEXT
*&---------------------------------------------------------------------*
*&      Form  VIM_GET_REFFIELD_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_REFFIELD  text
*      -->P_REFTABLE  text
*      <--P_DFIES Entry for ALV-Fieldcatalogue
*----------------------------------------------------------------------*
FORM vim_get_reffield_alv USING value(p_reffield) TYPE fieldname
                                value(p_reftable) TYPE tabname
                      CHANGING p_dfies TYPE dfies.

  DATA: dfies_tab TYPE TABLE OF dfies.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = p_reftable
      fieldname      = p_reffield
      langu          = sy-langu
    TABLES
      dfies_tab      = dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    READ TABLE dfies_tab INTO p_dfies INDEX 1.
  ENDIF.
ENDFORM.                               " VIM_GET_REFFIELD_ALV

*&---------------------------------------------------------------------*
*&      Form  CONV_DFIES_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_DFIES  text
*      <--P_P_FCAT_REFFIELD  text
*----------------------------------------------------------------------*
FORM conv_dfies_fcat USING    p_dfies LIKE dfies
                              i TYPE i
                    CHANGING p_fcat_reffield TYPE slis_fieldcat_alv.

  p_fcat_reffield-col_pos = i.
  p_fcat_reffield-fieldname = p_dfies-fieldname.
  p_fcat_reffield-ref_tabname = p_dfies-tabname.
  p_fcat_reffield-key = p_dfies-keyflag.
  p_fcat_reffield-seltext_l = p_dfies-scrtext_l.
  p_fcat_reffield-seltext_m = p_dfies-scrtext_m.
  p_fcat_reffield-seltext_s = p_dfies-scrtext_s.
  p_fcat_reffield-reptext_ddic = p_dfies-reptext.
  p_fcat_reffield-datatype = p_dfies-datatype.
  p_fcat_reffield-inttype = p_dfies-inttype.
  p_fcat_reffield-ddic_outputlen = p_dfies-outputlen.
  p_fcat_reffield-intlen = p_dfies-intlen.
  p_fcat_reffield-lowercase = p_dfies-lowercase.
  CASE p_dfies-datatype.
    WHEN 'CLNT'.
      CHECK x_header-clidep <> space AND p_fcat_reffield-key <> space.
      p_fcat_reffield-tech = 'X'.
    WHEN 'CURR'.
* currency field in structure
      p_fcat_reffield-cfieldname = p_dfies-reffield.
    WHEN 'QUAN'.
* currency field in structure
      p_fcat_reffield-qfieldname = p_dfies-reffield.
  ENDCASE.
ENDFORM.                               " CONV_DFIES_FCAT
*&---------------------------------------------------------------------*
*&      Form  INIT_ALV_VARIANT
*&---------------------------------------------------------------------*
*       define path for list variant names
*----------------------------------------------------------------------*
*      <--P_VARIANT  text
*      <--P_SAVE     text
*----------------------------------------------------------------------*
FORM init_alv_variant CHANGING p_save
                               p_default
                               p_variant STRUCTURE disvariant.

  CONCATENATE x_header-viewname sy-repid INTO p_variant-report.
  p_save = 'A'.
  p_default = 'X'.
ENDFORM.                               " INIT_ALV_VARIANT
*&---------------------------------------------------------------------*
*&      Form  ALV_END_OF_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_end_of_list.
  WRITE AT /(sy-linsz) sy-pagno CENTERED.
ENDFORM.                               " ALV_END_OF_LIST

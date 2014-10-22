*-------------------------------------------------------------------
***INCLUDE LSVIMFTX .
*-------------------------------------------------------------------
*&--------------------------------------------------------------------*
*&      Form  TABLE_CALL_FUNCTION                                     *
*---------------------------------------------------------------------*
* call function TABLEPROC with proper parameters
*---------------------------------------------------------------------*
* TCF_FCODE    ---> current function code                             *
* TCF_TABTYPE  ---> type of int. table: SHORT, MIDDLE, LONG, VERY_LONG*
* TCF_UPD_fLAG <--- flag: update required                             *
*---------------------------------------------------------------------*
FORM table_call_function TABLES dba_sellist dpl_sellist
                                x_header STRUCTURE vimdesc
                                x_namtab excl_cua_funct
                         USING value(tcf_fcode) value(tcf_tabtype)
                               tcf_upd_flag.

  DATA: function_name LIKE tfdir-funcname VALUE 'TABLEPROC_',
        prefix_len TYPE i VALUE '10'.                       "#EC STR_NUM

  READ TABLE x_header INDEX 1.
  MOVE x_header-area TO function_name+prefix_len.
  IF function_name CA forbidden_func_name_chars.
    PERFORM replace_forbidden_chars USING forbidden_func_name_chars
                                          function_name.
  ENDIF.
  CASE tcf_tabtype.
    WHEN 'ULTRA_SHORT'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_us
          total                    = total_us
        EXCEPTIONS                                          "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
    WHEN 'VERY_SHORT'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_vs
          total                    = total_vs
        EXCEPTIONS                                    "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
    WHEN 'SHORT'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_s
          total                    = total_s
        EXCEPTIONS                                        "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
    WHEN 'MIDDLE'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_m
          total                    = total_m
        EXCEPTIONS                                          "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
    WHEN 'LONG'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_l
          total                    = total_l
        EXCEPTIONS                                          "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
    WHEN 'VERY_LONG'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_vl
          total                    = total_vl
        EXCEPTIONS                                            "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
    WHEN 'ULTRA_LONG'.
      CALL FUNCTION function_name
        EXPORTING
          fcode                    = tcf_fcode
          view_action              = maint_mode
          view_name                = x_header-viewname
          corr_number              = corr_nbr
        IMPORTING
          ucomm                    = function
          update_required          = tcf_upd_flag
        TABLES
          dba_sellist              = dba_sellist
          dpl_sellist              = dpl_sellist
          excl_cua_funct           = excl_cua_funct
          x_header                 = x_header
          x_namtab                 = x_namtab
          corr_keytab              = e071k_tab
          extract                  = extract_ul
          total                    = total_ul
        EXCEPTIONS                                        "#EC FB_RC
          missing_corr_number      = 01
          saving_correction_failed = 03.
  ENDCASE.
ENDFORM.                               " TABLE_CALL_FUNCTION

*&--------------------------------------------------------------------*
*&      Form  TABLE_GET_DATA                                          *
*---------------------------------------------------------------------*
* get data from database
*---------------------------------------------------------------------*
FORM table_get_data.
  CONSTANTS maxsellines TYPE i VALUE 500.
  DATA: tgd_sellist LIKE vimsellist OCCURS 10, tgd_sel LIKE vimsellist,
        tgd_sellangu LIKE vimsellist,
        short_sellist LIKE vimsellist OCCURS 10,
        short_sel LIKE vimsellist,
        tgd_ind TYPE i, tgd_field LIKE vimnamtab-viewfield,  "#EC NEEDED
        selnumber TYPE i, selindex TYPE i, selcut TYPE i,
        selpieces TYPE i.
  FIELD-SYMBOLS: <text_key>.                               "#EC *
  DATA: primtab TYPE REF TO data, texttab TYPE REF TO data,
        w_texttab_save TYPE REF TO data, w_texttab TYPE REF TO data,
        text_keyflds TYPE vim_flds_tab_type.
  DATA: append_flag(1) TYPE c.

  FIELD-SYMBOLS: <primtab> TYPE STANDARD TABLE,
                 <texttab> TYPE SORTED TABLE, <w_texttab> TYPE ANY,
                 <w_texttab_save> TYPE ANY, <textline_x> TYPE x.

  REFRESH total. CLEAR total.
  IF x_header-selection NE space.
    DESCRIBE TABLE dba_sellist LINES selnumber.
    IF selnumber > maxsellines.  "fragmentation of too large sellists
      CLEAR selpieces.
      CLEAR selindex.
      CREATE DATA primtab TYPE STANDARD TABLE OF (x_header-maintview).
      ASSIGN primtab->* TO <primtab>.
      WHILE selindex < selnumber.
        selpieces = selpieces + maxsellines.
        REFRESH short_sellist.
        CLEAR selcut.
        WHILE selcut EQ 0 AND selindex < selnumber.
          selindex = selindex + 1.
          READ TABLE dba_sellist INTO short_sel INDEX selindex.
          APPEND short_sel TO short_sellist.
          IF selindex > selpieces AND short_sel-and_or NE 'AND'.
            selcut = 1.
          ENDIF.
        ENDWHILE.
        CLEAR short_sel-and_or.      "last line without logic operation
        MODIFY short_sellist FROM short_sel INDEX selindex.
        CALL FUNCTION 'VIEW_FILL_WHERETAB'
           EXPORTING
                tablename               = x_header-maintview
*           ONLY_CNDS_FOR_KEYFLDS   = 'X' "use default SPACE
           TABLES
                sellist                 = short_sellist
                wheretab                = vim_wheretab
                x_namtab                = x_namtab
           EXCEPTIONS                                      "#EC *
                no_conditions_for_table = 01.
*       read data from database with morer wheretabs...................*
        SELECT * FROM (x_header-maintview) APPENDING TABLE <primtab>
                                          WHERE (vim_wheretab).
        CLEAR selcut.
      ENDWHILE.
    ELSE.                                  "selnumber > maxsellines
      CALL FUNCTION 'VIEW_FILL_WHERETAB'
           EXPORTING
                tablename               = x_header-maintview
*         ONLY_CNDS_FOR_KEYFLDS   = 'X' "use default SPACE
           TABLES
                sellist                 = dba_sellist
                wheretab                = vim_wheretab
                x_namtab                = x_namtab
           EXCEPTIONS                                       "#EC *
                no_conditions_for_table = 01.
*   read data from database with one wheretab..........................*
      CREATE DATA primtab TYPE STANDARD TABLE OF (x_header-maintview)."UCb
      ASSIGN primtab->* TO <primtab>.
      SELECT * FROM (x_header-maintview) INTO TABLE <primtab>
                                          WHERE (vim_wheretab).
    ENDIF.                                   "if selnumber > maxsellines
  ELSE.                                  "if x_header-selection NE space
    REFRESH vim_wheretab.
*   read data from database without wheretab...........................*
    CREATE DATA primtab TYPE STANDARD TABLE OF (x_header-maintview)."UCb
    ASSIGN primtab->* TO <primtab>.
    SELECT * FROM (x_header-maintview) INTO TABLE <primtab>.
  ENDIF.                                "if x_header-selection NE space
  IF x_header-texttbexst EQ space.
* no texttable
    LOOP AT <primtab> INTO <vim_total_struc>.
      APPEND total.
    ENDLOOP.                                                "UCe
    SORT total BY <vim_xtotal_key>. <status>-alr_sorted = 'R'.
    IF x_header-selection EQ space AND x_header-delmdtflag NE space.
* time dependence
      PERFORM build_mainkey_tab_0.
    ENDIF.
    LOOP AT total.
      CLEAR: <action>, <mark>.
      MODIFY total.
      IF x_header-selection EQ space AND x_header-delmdtflag NE space.
        PERFORM build_mainkey_tab_1.
      ENDIF.
    ENDLOOP.
    IF x_header-selection EQ space AND x_header-delmdtflag NE space.
      PERFORM build_mainkey_tab_2.
    ENDIF.
  ELSE.
* texttable exists
    PERFORM vim_get_text_keyflds USING x_header-texttab
                                 CHANGING text_keyflds.
    CREATE DATA texttab TYPE SORTED TABLE OF (x_header-texttab)
     WITH UNIQUE KEY (text_keyflds).                        "UCb
    ASSIGN texttab->* TO <texttab>.
    IF x_header-selection NE space.
* get selection for texttable
*      READ TABLE dba_sellist INTO dpl_sellist INDEX 1.
      DESCRIBE TABLE dba_sellist LINES selnumber.
      selindex = 0.
      WHILE selindex < selnumber.
        selindex = selindex + 1.
        READ TABLE dba_sellist INTO tgd_sel INDEX selindex.
        READ TABLE x_namtab WITH KEY
          viewfield = tgd_sel-viewfield texttabfld = space. "#EC *
        CHECK x_namtab-keyflag = 'X'.        " key fields for texttab only
        tgd_sel-viewfield = x_namtab-txttabfldn.
        READ TABLE x_namtab WITH KEY
          viewfield = tgd_sel-viewfield texttabfld = 'X'.
        tgd_sel-tabix = sy-tabix.
        CLEAR append_flag.
        IF sy-subrc EQ 0."Otherwise keyfld in tab not in txttab HW696310
          append_flag = 'X'.
        ENDIF.
        IF tgd_sel-and_or NE 'AND' OR selindex = 1.       "Langufield
          READ TABLE x_namtab WITH KEY primtabkey = 0 keyflag = 'X'."#EC *
          tgd_sellangu-viewfield = x_namtab-viewfield.
          tgd_sellangu-tabix     = sy-tabix.
          tgd_sellangu-operator = 'EQ'.
          tgd_sellangu-value = sy-langu.
          tgd_sellangu-and_or = 'AND'.
          IF tgd_sellangu-value EQ space.
            tgd_sellangu-initial = 'X'.
          ENDIF.
          tgd_sellangu-cond_kind = dpl_sellist-cond_kind.
          CLEAR tgd_sellangu-converted.
          APPEND tgd_sellangu TO tgd_sellist.
        ENDIF.
        IF append_flag EQ 'X'.
          APPEND tgd_sel TO tgd_sellist.
        ENDIF.
*      Did not work for sellist to describe more than one dataset in
*      transport request                                          "HCG
*      LOOP AT x_namtab WHERE keyflag NE space    "fill sellist for
*                         AND texttabfld NE space. "texttab
*        tgd_field = x_namtab-viewfield.
*        tgd_ind   = sy-tabix.
*        IF x_namtab-primtabkey EQ 0.   "langufield
*          tgd_sel-viewfield = tgd_field.
*          tgd_sel-tabix     = tgd_ind.
*          tgd_sel-operator = 'EQ'.
*          tgd_sel-value = sy-langu.
*          tgd_sel-and_or = 'AND'.
*          IF tgd_sel-value EQ space.
*            tgd_sel-initial = 'X'.
*          ENDIF.
*          tgd_sel-cond_kind = dpl_sellist-cond_kind.
*          clear tgd_sel-converted.
*          APPEND tgd_sel TO tgd_sellist.
*        ELSE.
*          READ TABLE x_namtab INDEX x_namtab-primtabkey.
*          LOOP AT dba_sellist WHERE viewfield EQ x_namtab-viewfield.
*            tgd_sel = dba_sellist.
*            tgd_sel-viewfield = tgd_field.
*            tgd_sel-tabix     = tgd_ind.
*            IF tgd_sel-and_or EQ space.
*              tgd_sel-and_or = 'AND'.
*            ENDIF.
*            APPEND tgd_sel TO tgd_sellist.
*          ENDLOOP.
*        ENDIF.
*      ENDLOOP.
      ENDWHILE.
      DESCRIBE TABLE tgd_sellist.
      READ TABLE tgd_sellist INDEX sy-tfill INTO tgd_sel.
      IF tgd_sel-and_or NE space.
        CLEAR tgd_sel-and_or.
        MODIFY tgd_sellist INDEX sy-tfill FROM tgd_sel.
      ENDIF.
    ELSE.
* no selection for primary table: fill selection with langu-field only
      LOOP AT x_namtab WHERE keyflag NE space    "fill sellist with
                         AND texttabfld NE space  "language condition
                         AND primtabkey EQ 0.
        tgd_sel-viewfield = x_namtab-viewfield.
        tgd_sel-tabix     = sy-tabix.
        tgd_sel-operator = 'EQ'.
        tgd_sel-value = sy-langu.
        tgd_sel-and_or = space.
        IF tgd_sel-value EQ space.
          tgd_sel-initial = 'X'.
        ENDIF.
        APPEND tgd_sel TO tgd_sellist.
        EXIT.
      ENDLOOP.
    ENDIF.
*    CALL FUNCTION 'VIEW_FILL_WHERETAB'
*      EXPORTING
*        tablename               = x_header-texttab
*        only_cnds_for_keyflds   = 'X'
*      TABLES
*        sellist                 = tgd_sellist
*        wheretab                = vim_wheretab
*        x_namtab                = x_namtab
*      EXCEPTIONS
*        no_conditions_for_table = 01.
** read texttable from database
*    SELECT * FROM (x_header-texttab) INTO TABLE <texttab>
*                                      WHERE (vim_wheretab).
    DESCRIBE TABLE tgd_sellist LINES selnumber.
    IF selnumber > maxsellines.  "fragmentation of too large sellists
      CLEAR selpieces.
      CLEAR selindex.
      WHILE selindex < selnumber.
        selpieces = selpieces + maxsellines.
        REFRESH short_sellist.
        CLEAR selcut.
        WHILE selcut EQ 0 AND selindex < selnumber.
          selindex = selindex + 1.
          READ TABLE tgd_sellist INTO short_sel INDEX selindex.
          APPEND short_sel TO short_sellist.
          IF selindex > selpieces AND short_sel-and_or NE 'AND'.
            selcut = 1.
          ENDIF.
        ENDWHILE.
        CLEAR short_sel-and_or.      "last line without logic operation
        MODIFY short_sellist FROM short_sel INDEX selindex.
        CALL FUNCTION 'VIEW_FILL_WHERETAB'
          EXPORTING
            tablename               = x_header-texttab
            only_cnds_for_keyflds   = 'X'
          TABLES
            sellist                 = short_sellist
            wheretab                = vim_wheretab
            x_namtab                = x_namtab
          EXCEPTIONS                                       "#EC *
            no_conditions_for_table = 01.
*       read data from database with morer wheretabs...................*
        SELECT * FROM (x_header-texttab) APPENDING TABLE <texttab>
                                          WHERE (vim_wheretab).
        CLEAR selcut.
      ENDWHILE.
    ELSE.                                  "selnumber > maxsellines
      CALL FUNCTION 'VIEW_FILL_WHERETAB'
        EXPORTING
          tablename               = x_header-texttab
          only_cnds_for_keyflds   = 'X'
        TABLES
          sellist                 = tgd_sellist
          wheretab                = vim_wheretab
          x_namtab                = x_namtab
        EXCEPTIONS                                          "#EC *
          no_conditions_for_table = 01.
*   read data from database with one wheretab..........................*
      SELECT * FROM (x_header-texttab) INTO TABLE <texttab>
                                        WHERE (vim_wheretab).
    ENDIF.                                   "if selnumber > maxsellines
    IF x_header-selection EQ space AND x_header-delmdtflag NE space.
      PERFORM build_mainkey_tab_0.
    ENDIF.
    CREATE DATA w_texttab_save TYPE (x_header-texttab).
    CREATE DATA w_texttab TYPE (x_header-texttab).
    ASSIGN: w_texttab->* TO <w_texttab>,
            w_texttab_save->* TO <w_texttab_save>,
            <w_texttab_save> TO <textline_x> CASTING.
    LOOP AT <primtab> INTO <vim_total_struc>.
*       hier aufbauen schlüssel texttabelle in feld text_key
      CLEAR <w_texttab>.
      PERFORM fill_texttab_key_uc USING <vim_total_struc>
                                  CHANGING <w_texttab>.
      IF <w_texttab> NE <w_texttab_save>.
        READ TABLE <texttab> INTO <w_texttab_save>
         FROM <w_texttab>.
        IF sy-subrc = 0.
*          MOVE <w_texttab_save> TO <w_textline>.
*          MOVE textline(x_header-texttablen) TO <total_text>.
        ELSE.
          MOVE <text_initial> TO <w_texttab_save>.
        ENDIF.
*      ELSE.
*        MOVE <w_texttab_save> TO <w_textline>.
*        MOVE textline(x_header-texttablen) TO <total_text>.
      ENDIF.
      MOVE <textline_x> TO <vim_xtotal_text>.
      CLEAR: <action>, <mark>, <action_text>.
      APPEND total.
      IF x_header-selection EQ space AND x_header-delmdtflag NE space.
        PERFORM build_mainkey_tab_1.
      ENDIF.
    ENDLOOP.
    SORT total BY <vim_xtotal_key>. <status>-alr_sorted = 'R'.
    IF x_header-selection EQ space AND x_header-delmdtflag NE space.
      PERFORM build_mainkey_tab_2.
    ENDIF.
  ENDIF.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ENDIF.
ENDFORM.                               " TABLE_GET_DATA

*&--------------------------------------------------------------------*
*&      Form  TABLE_DB_UPD                                            *
*---------------------------------------------------------------------*
* process data base updates/inserts/deletes
*---------------------------------------------------------------------*
FORM table_db_upd.
  DATA: modified_entries TYPE i, prt_frky_entries TYPE i, rc TYPE i,
        h_ix TYPE i,
        primtab_mod TYPE REF TO data,
        primtab_mod_wa TYPE REF TO data,
        texttab_mod TYPE REF TO data,
        w_texttab_mod TYPE REF TO data,
        e071_loctab TYPE vim_ko200_tab_type.   "#EC NEEDED
  FIELD-SYMBOLS: <mod_elem_tab> TYPE STANDARD TABLE,
                 <h_keyx> TYPE x,                           "#EC *
                 <mod_elem_wa> TYPE ANY,
                 <texttab> TYPE STANDARD TABLE, <w_texttab> TYPE ANY,
                 <textline_x> TYPE x.

* first of all: delete requests
  CREATE DATA primtab_mod TYPE TABLE OF (x_header-maintview).
  CREATE DATA primtab_mod_wa TYPE (x_header-maintview).
  ASSIGN: primtab_mod->* TO <mod_elem_tab>,
          primtab_mod_wa->* TO <mod_elem_wa>.
  LOOP AT total.
    CHECK ( <action> EQ geloescht OR <action> EQ update_geloescht OR
            <action> EQ neuer_geloescht ).
    IF <action> EQ neuer_geloescht.
      IF status-delete EQ geloescht.
        READ TABLE extract WITH KEY <vim_xtotal_key>.       "#EC *
        IF sy-subrc EQ 0.
          DELETE extract INDEX sy-tabix.
        ENDIF.
      ENDIF.
      DELETE total.
    ELSE.
      APPEND <vim_total_struc> TO <mod_elem_tab>.
      ADD 1 TO modified_entries.
      IF x_header-texttbexst EQ space. "no texttab
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.     "#EC *
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF modified_entries NE 0.
    DELETE (x_header-maintview) FROM TABLE <mod_elem_tab>.
  ENDIF.
  IF x_header-texttbexst NE space.
    CLEAR modified_entries.
    CREATE DATA texttab_mod TYPE STANDARD TABLE OF (x_header-texttab).
    CREATE DATA w_texttab_mod TYPE (x_header-texttab).
    ASSIGN: texttab_mod->* TO <texttab>,
            w_texttab_mod->* TO <w_texttab>,
            <w_texttab> TO <textline_x> CASTING.
* delete texts for all deleted entities
    LOOP AT <mod_elem_tab> INTO <table1_wa>.
      READ TABLE total WITH KEY <f1_wax> BINARY SEARCH.     "#EC *
      h_ix = sy-tabix.
      IF x_header-ptfrkyexst NE space.
* partial foreign key relation:
* Are there still any primary table entries?
        PERFORM create_wheretab_new USING x_namtab[]
                                          <vim_total_struc>
                                          <vim_tot_txt_struc>
                                          x_header-maintview
                                          'X' rc.
        IF rc NE 0.                    "something seems to be wrong
          prt_frky_entries = 1.        "don't delete
        ELSE.
          SELECT COUNT(*) FROM (x_header-maintview) UP TO 1 ROWS
                          WHERE (vim_wheretab).
          prt_frky_entries = sy-dbcnt.
        ENDIF.
      ELSE.
        CLEAR prt_frky_entries.
      ENDIF.
      IF prt_frky_entries EQ 0.
* No, there aren't.
*        MODIFY mod_elem_tab FROM <total_text>.
        MOVE <vim_xtotal_text> TO <textline_x>.
        APPEND <w_texttab> TO <texttab>.
        ADD 1 TO modified_entries.
      ENDIF.
      IF status-delete EQ geloescht.
        READ TABLE extract WITH KEY <vim_xtotal_key>        "#EC *
         TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          DELETE extract INDEX sy-tabix.
        ENDIF.
      ENDIF.
      DELETE total INDEX h_ix.
    ENDLOOP.
    IF modified_entries NE 0.
* delete text entries in all languages
      DO modified_entries TIMES.
*        READ TABLE mod_elem_tab INDEX 1.
*        DELETE mod_elem_tab INDEX 1.
*        READ TABLE <texttab> INTO <w_texttab> INDEX 1.
        READ TABLE <texttab> INTO <vim_tot_txt_struc> INDEX 1."IG 862951
        DELETE <texttab> INDEX 1.                           "IG 862951
*        PERFORM create_wheretab TABLES x_namtab
*                                USING mod_elem_tab
*                                      x_header-texttab space rc.

        PERFORM create_wheretab_new USING x_namtab[]
                                          <vim_total_struc>
                                          <vim_tot_txt_struc>
                                          x_header-texttab
                                          space
                                          rc.
        SELECT * FROM (x_header-texttab) APPENDING TABLE <texttab>
                                         WHERE (vim_wheretab).
      ENDDO.
*      DELETE (x_header-texttab) FROM TABLE mod_elem_tab.
      DELETE (x_header-texttab) FROM TABLE <texttab>.
    ENDIF.
  ENDIF.
* now update requests
  REFRESH: <mod_elem_tab>.
  CLEAR modified_entries.
  LOOP AT total.
    CHECK <action> EQ aendern.
*    MOVE: total TO <table1>,
*          <table1> TO mod_elem_tab.
*    APPEND mod_elem_tab.
    APPEND <vim_total_struc> TO <mod_elem_tab>.
    ADD 1 TO modified_entries.
    IF x_header-texttbexst EQ space OR
       <action_text> EQ original.
      READ TABLE extract WITH KEY <vim_xtotal_key>.         "#EC *
      <action> = original.
      IF sy-subrc = 0.
        <xact> = original.
        MODIFY extract INDEX sy-tabix.
      ENDIF.
      MODIFY total.
    ENDIF.
  ENDLOOP.
  IF modified_entries NE 0.
*------------------*--------------------------------------------
* Changes done on 07.08/2009 to handle Checkman errors. DUTTAN.
*--------------------------------------------------------------
* Start - Handling exceptions for Unique Indexes.
*    TRY.
        UPDATE (x_header-maintview) FROM TABLE <mod_elem_tab>.
*      CATCH cx_sy_open_sql_db.
*        MESSAGE i862(sv).
*    ENDTRY.
* End - handling.
*---------------------------------------------------------------
* End of  Change. 07/08/2009 DUTTAN.
*---------------------------------------------------------------
  ENDIF.
  IF x_header-texttbexst NE space.
    REFRESH <texttab>.
    CLEAR modified_entries.
    LOOP AT total.
      CHECK <action_text> EQ aendern.
*      MOVE: <total_text> TO mod_elem_tab.
*      APPEND mod_elem_tab.
      MOVE <vim_xtotal_text> TO <textline_x>.
      APPEND <w_texttab> TO <texttab>.
      ADD 1 TO modified_entries.
      READ TABLE extract WITH KEY <vim_xtotal_key>.        "#EC *
      IF <action> EQ aendern.
        <action> = original. <xact> = original.
      ENDIF.
      <action_text> = original. <xact_text> = original.
      IF sy-subrc = 0.
        MODIFY extract INDEX sy-tabix.
      ENDIF.
      MODIFY total.
    ENDLOOP.
    IF modified_entries NE 0.
*      UPDATE (x_header-texttab) FROM TABLE mod_elem_tab.
      UPDATE (x_header-texttab) FROM TABLE <texttab>.
    ENDIF.
  ENDIF.
* last not least: insert requests
  REFRESH: <mod_elem_tab>. CLEAR modified_entries.
  LOOP AT total.
    CHECK <action> EQ neuer_eintrag.
*    MOVE: total TO <table1>,
*          <table1> TO mod_elem_tab.
*    APPEND mod_elem_tab.
    APPEND <vim_total_struc> TO <mod_elem_tab>.
    ADD 1 TO modified_entries.
    IF x_header-texttbexst EQ space OR
       <action_text> EQ original.
      READ TABLE extract WITH KEY <vim_xtotal_key>.         "#EC *
      <action> = original.
      IF sy-subrc = 0.
        <xact> = original.
        MODIFY extract INDEX sy-tabix.
      ENDIF.
      MODIFY total.
    ENDIF.
  ENDLOOP.
  IF modified_entries NE 0.
*------------------*--------------------------------------------
* Changes done on 07.08/2009 to handle Checkman errors. DUTTAN.
*--------------------------------------------------------------
* Start - Handling exceptions for Unique Indexes.
*    TRY.
        INSERT (x_header-maintview) FROM TABLE <mod_elem_tab>.
*      CATCH cx_sy_open_sql_db.
*        MESSAGE i862(sv).
*    ENDTRY.
* End - Handling.
*---------------------------------------------------------------
* End of  Change. 07/08/2009 DUTTAN.
*---------------------------------------------------------------
  ENDIF.
  IF x_header-texttbexst NE space.
    REFRESH <texttab>.
    CLEAR modified_entries.
    LOOP AT total.
      CHECK <action_text> EQ neuer_eintrag.
*      MOVE: <total_text> TO mod_elem_tab.
*      APPEND mod_elem_tab.
      MOVE <vim_xtotal_text> TO <textline_x>.
      APPEND <w_texttab> TO <texttab>.
      ADD 1 TO modified_entries.
      READ TABLE extract WITH KEY <vim_xtotal_key>.         "#EC *
      IF <action> EQ neuer_eintrag.
        <action> = original. <xact> = original.
      ENDIF.
      <action_text> = original. <xact_text> = original.
      IF sy-subrc = 0.
        MODIFY extract INDEX sy-tabix.
      ENDIF.
      MODIFY total.
    ENDLOOP.
    IF modified_entries NE 0.
*      INSERT (x_header-texttab) FROM TABLE mod_elem_tab
*                                ACCEPTING DUPLICATE KEYS.
      INSERT (x_header-texttab) FROM TABLE <texttab>
                                ACCEPTING DUPLICATE KEYS.
      IF sy-subrc NE 0. "duplicate keys -> process additional update
*        UPDATE (x_header-texttab) FROM TABLE mod_elem_tab.
        UPDATE (x_header-texttab) FROM TABLE <texttab>.
      ENDIF.
    ENDIF.
  ENDIF.
*    Call synchronizer
*  REFRESH e071_loctab.
*  APPEND e071 TO e071_loctab.
*  PERFORM vim_synchronizer_call
*                USING e071_loctab[]
*                      corr_keytab[]
*                      'X'.

  CLEAR: <status>-upd_flag,
         <status>-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.                               " TABLE_DB_UPD

*&--------------------------------------------------------------------*
*&      Form  TABLE_READ_SINGLE_ENTRY                                 *
*---------------------------------------------------------------------*
* read single entry from data base
*---------------------------------------------------------------------*
FORM table_read_single_entry.
  DATA: tab TYPE REF TO data, texttab TYPE REF TO data,
        textline TYPE REF TO data.

  FIELD-SYMBOLS: <tab> TYPE STANDARD TABLE,
                 <texttab> TYPE STANDARD TABLE,
                 <textline> TYPE ANY, <textline_x> TYPE x.

  CREATE DATA tab TYPE STANDARD TABLE OF (x_header-maintview).
  ASSIGN tab->* TO <tab>.
*  REFRESH mod_elem_tab.
*  MOVE <f1> TO gen_key.
  CALL FUNCTION 'DB_SELECT_GENERIC_TABLE'
       EXPORTING
            tablename   = x_header-maintview
*     genkey      = gen_key
            genkey      = <f1_x>
            genkey_ln   = x_header-keylen
       TABLES
*     inttab      = mod_elem_tab
            inttab      = <tab>
       EXCEPTIONS
            db_error    = 12
            not_found   = 04
            wrong_param = 08.
  IF sy-subrc > 4. RAISE get_table_error. ENDIF.
*  READ TABLE mod_elem_tab INDEX 1.
  READ TABLE <tab> INTO <table1> INDEX 1.
  IF sy-subrc <> 0.
    MOVE <initial> TO <table1>.
*  ELSE.
*    <table1> = mod_elem_tab.
  ENDIF.
  IF x_header-texttbexst NE space.
* read text table
    CREATE DATA texttab TYPE STANDARD TABLE OF (x_header-texttab).
    CREATE DATA textline TYPE (x_header-texttab).
    ASSIGN: texttab->* TO <texttab>,
            textline->* TO <textline>,
            <textline> TO <textline_x> CASTING.
*    REFRESH mod_elem_tab.
*    CLEAR gen_key.
*    WRITE <table1_text> TO gen_key(x_header-textkeylen).
    CALL FUNCTION 'DB_SELECT_GENERIC_TABLE'
         EXPORTING
              tablename   = x_header-texttab
*       genkey      = gen_key
              genkey      = <textkey_x>
              genkey_ln   = x_header-textkeylen
         TABLES
*       inttab      = mod_elem_tab
              inttab      = <texttab>
         EXCEPTIONS
              db_error    = 12
              not_found   = 04
              wrong_param = 08.
    IF sy-subrc > 4. RAISE get_table_error. ENDIF.
*    READ TABLE mod_elem_tab INDEX 1.
    READ TABLE <texttab> INTO <table1_text> INDEX 1.
    IF sy-subrc <> 0.
      MOVE <text_initial> TO <table1_text>.
      CLEAR sy-subrc.
*    ELSE.
*      <table1_text> = mod_elem_tab.
    ENDIF.
  ENDIF.
ENDFORM.                               " TABLE_READ_SINGLE_ENTRY

*&--------------------------------------------------------------------*
*&      Form  SET_TXT_UPDATE_FLAG                                     *
*---------------------------------------------------------------------*
* note, if texttab entry was modified on screen
*---------------------------------------------------------------------*
FORM set_txt_update_flag.

  DATA: lb_als TYPE REF TO IF_EX_VIM_ALS_BADI.

  IF <textkey_x> EQ <initial_textkey_x> OR "textkey not filled yet OR
     status-action EQ kopieren OR      "copy mode              OR
     neuer EQ 'J' OR <xact> EQ leer OR "real new entry         OR
     ( temporal_delimitation_happened EQ 'X' AND "temporal delimitation
        x_header-delmdtflag EQ 'B' ).
    PERFORM fill_texttab_key_uc USING <table1> <table1_text>."#EC ..
  ENDIF.
  IF status-action EQ hinzufuegen.
    <status>-upd_flag = 'X'.           "always both tables must be added
  ELSE.
    TRANSLATE <status>-upd_flag USING ' TEX'.
  ENDIF.

  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      null_instance_accepted        = seex_false
      exit_name                     = 'VIM_ALS_BADI'
    CHANGING
      instance                      = lb_als
    EXCEPTIONS
      no_reference                  = 1
      no_interface_reference        = 2
      no_exit_interface             = 3
      class_not_implement_interface = 4
      single_exit_multiply_active   = 5
      cast_error                    = 6
      exit_not_existing             = 7
      data_incons_in_exit_managem   = 8
      OTHERS                        = 9.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
    CALL METHOD lb_als->enable_als
      EXPORTING
        view_name   = x_header-viewname
      IMPORTING
        als_enabled = als_enabled.

    IF als_enabled = 'X' AND
       ( <status>-upd_flag EQ 'T' OR  <status>-upd_flag EQ 'X' ).
      PERFORM VIM_MULTI_LANGU_TEXT_ALS.
    ENDIF.
  ENDIF.

ENDFORM.                               " SET_TXT_UPDATE_FLAG

*&--------------------------------------------------------------------*
*&      Form  FILL_TEXTTAB_KEY                                        *
*&--------------------------------------------------------------------*
*       Kept for downward compatibility only. Never use in unicode-
*       system. Use FILL_TEXTTAB_KEY instead                          *
*&--------------------------------------------------------------------*
FORM fill_texttab_key USING enti_wa text_wa.
  FIELD-SYMBOLS: <enti>, <text>.
  DATA: index TYPE i.
  LOOP AT x_namtab WHERE texttabfld NE space
                     AND keyflag NE space.   "all keyfields of text table
    index = x_namtab-position - x_header-tablen.
    ASSIGN text_wa+index(x_namtab-flength) TO <text>.
    IF x_namtab-primtabkey EQ space.   "language key
      MOVE sy-langu TO <text>.
    ELSE.
      index = x_namtab-primtabkey.
      READ TABLE x_namtab INDEX index.   "corresponding field of entity tb
      IF sy-subrc EQ 0.
        ASSIGN enti_wa+x_namtab-position(x_namtab-flength) TO <enti>.
        MOVE <enti> TO <text>.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               "FILL_TEXTTAB_KEY

*&--------------------------------------------------------------------*
*&      Form  FILL_TEXTTAB_KEY_UC                                     *
*&--------------------------------------------------------------------*
* ENTI_WA ---> WA of entity table                                     *
* TEXT_WA <--- WA of text table                                       *
*&--------------------------------------------------------------------*
FORM fill_texttab_key_uc USING enti_wa
                         CHANGING text_wa.
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab, <namtab2> TYPE vimnamtab,
                 <enti> TYPE ANY, <text> TYPE ANY.
  DATA: index TYPE i.
  LOOP AT x_namtab ASSIGNING <namtab> WHERE texttabfld NE space
                     AND keyflag NE space.
* keyfield of text table
    ASSIGN COMPONENT <namtab>-viewfield OF STRUCTURE text_wa
     TO <text>.
    IF <namtab>-primtabkey EQ space.   "language key
      MOVE sy-langu TO <text>.
    ELSE.
      index = <namtab>-primtabkey.
      READ TABLE x_namtab ASSIGNING <namtab2> INDEX index.
* corresponding field of entity tb
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT <namtab2>-viewfield OF STRUCTURE enti_wa
         TO <enti>.
        MOVE <enti> TO <text>.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               "FILL_TEXTTAB_KEY_UC

*&--------------------------------------------------------------------*
*&      Form CREATE_WHERETAB_NEW                                      *
*&--------------------------------------------------------------------*
* create where-tab for dynamic select                                 *
*&--------------------------------------------------------------------*
*        --> CW_TOTAL        table line
*            CW_TABLE        table the wheretab has to be filled for
*            CW_ENTI_KEY
*            CW_RC
*&--------------------------------------------------------------------*
FORM create_wheretab_new USING cw_namtab LIKE x_namtab[]
                               total_struc TYPE any
                               total_txt_struc TYPE any
                               value(cw_table) LIKE vimdesc-viewname
                               value(cw_enti_key) TYPE xfeld
                               cw_rc TYPE i.

  DATA: cw_sellist LIKE vimsellist OCCURS 10,
        cw_sel LIKE vimsellist,
        first(1) TYPE c VALUE 'X', w_namtab TYPE vimnamtab,
        flength_in_char TYPE i.
  FIELD-SYMBOLS: <cw_value> TYPE ANY,
                 <w_namtab2> TYPE vimnamtab.

  LOOP AT cw_namtab INTO w_namtab
                    WHERE keyflag NE space    "all textkeyfields
                      AND texttabfld NE space "with relations to
                      AND primtabkey NE 0.    "entity key fields
    CHECK w_namtab-datatype NE 'CLNT' OR first EQ space.
    TRANSLATE first USING 'X '.
*    IF cw_enti_key EQ space.
*      SUBTRACT x_header-tablen FROM w_namtab-position.
*    ENDIF.
*    ASSIGN cw_total+w_namtab-position(w_namtab-flength) "value of
*              TO <cw_value>.           "textkey
    IF cw_enti_key NE space.
      READ TABLE cw_namtab INDEX w_namtab-primtabkey
       ASSIGNING <w_namtab2>.           "corresp. enti key
      ASSIGN COMPONENT <w_namtab2>-viewfield OF
       STRUCTURE total_struc TO <cw_value>.
      cw_sel-viewfield = <w_namtab2>-viewfield.
    ELSE.
      ASSIGN COMPONENT w_namtab-viewfield OF
       STRUCTURE total_txt_struc TO <cw_value>.
      cw_sel-viewfield = w_namtab-viewfield.
    ENDIF.
    cw_sel-tabix     = sy-tabix.
    cw_sel-operator = 'EQ'.
    cw_sel-and_or = 'AND'.
    CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
         EXPORTING
              tabname      = cw_table
              fieldname    = cw_sel-viewfield
              value_intern = <cw_value>
*       inttype      = w_namtab-inttype
*       datatype     = w_namtab-datatype
*       decimals     = w_namtab-decimals
*       convexit     = w_namtab-convexit
*       sign         = w_namtab-sign
              outputlen    = w_namtab-outputlen
              intlen       = w_namtab-flength
         IMPORTING
              value_extern = cw_sel-value.
    IF cw_sel-value EQ space.
      cw_sel-initial = 'X'.
    ENDIF.
    flength_in_char =
                  w_namtab-flength / cl_abap_char_utilities=>charsize.
    CASE w_namtab-inttype.
      WHEN 'F'. cw_sel-fltp_value = <cw_value>.
      WHEN 'D'. cw_sel-date_value = <cw_value>.
      WHEN 'T'. cw_sel-time_value = <cw_value>.
*      WHEN 'P'. cw_sel-pckd_value(w_namtab-flength) = <cw_value>.
      WHEN 'P'. cw_sel-raw_value(w_namtab-flength) = <cw_value>.
      WHEN 'N'. cw_sel-numc_value(flength_in_char) = <cw_value>.
      WHEN 'C'. cw_sel-invd_value(flength_in_char) = <cw_value>.
      WHEN 'I'. cw_sel-int4_value = <cw_value>.
      WHEN 'X'.
        CASE w_namtab-datatype.
          WHEN 'INT1'. cw_sel-int1_value = <cw_value>.
          WHEN 'INT2'. cw_sel-int2_value = <cw_value>.
          WHEN 'INT4'. cw_sel-int4_value = <cw_value>.
          WHEN 'RAW'. cw_sel-raw_value(w_namtab-flength) = <cw_value>.
        ENDCASE.
    ENDCASE.
    cw_sel-converted = 'X'.
    APPEND cw_sel TO cw_sellist.
    CLEAR cw_sel.
  ENDLOOP.
  DESCRIBE TABLE cw_sellist.
  READ TABLE cw_sellist INTO cw_sel INDEX sy-tfill.
  IF cw_sel-and_or NE space.
    CLEAR cw_sel-and_or. MODIFY cw_sellist INDEX sy-tfill FROM cw_sel.
  ENDIF.
  CALL FUNCTION 'VIEW_FILL_WHERETAB'
    EXPORTING
      tablename               = cw_table
      only_cnds_for_keyflds   = 'X'
    TABLES
      sellist                 = cw_sellist
      wheretab                = vim_wheretab
      x_namtab                = cw_namtab
    EXCEPTIONS
      no_conditions_for_table = 01.
  cw_rc = sy-subrc.
ENDFORM.                               "create_wheretab_new
*&--------------------------------------------------------------------*
*&      Form CREATE_WHERETAB                                          *
*&--------------------------------------------------------------------*
*       Kept for downward compatibility only. Never use in unicode-
*       system. Use CREATE_WHERETAB_NEW instead.
*&--------------------------------------------------------------------*
*        --> CW_TOTAL        table line
*            CW_TABLE        table name
*            CW_ENTI_KEY
*            CW_RC
*&--------------------------------------------------------------------*
FORM create_wheretab TABLES cw_namtab STRUCTURE vimnamtab
                     USING value(cw_total)
                           value(cw_table) LIKE vimdesc-viewname
                           value(cw_enti_key) TYPE c
                           cw_rc TYPE i.
  DATA: cw_sellist LIKE vimsellist OCCURS 10, cw_sel LIKE vimsellist,
        first(1) TYPE c VALUE 'X'.
  FIELD-SYMBOLS: <cw_value>.

  LOOP AT cw_namtab WHERE keyflag NE space    "all textkeyfields
                      AND texttabfld NE space "with relations to
                      AND primtabkey NE 0.      "entity key fields
    CHECK cw_namtab-datatype NE 'CLNT' OR first EQ space.
    TRANSLATE first USING 'X '.
    IF cw_enti_key EQ space.
      SUBTRACT x_header-tablen FROM cw_namtab-position.
    ENDIF.
    ASSIGN cw_total+cw_namtab-position(cw_namtab-flength) "value of
              TO <cw_value>.           "textkey
    IF cw_enti_key NE space.
      READ TABLE cw_namtab INDEX cw_namtab-primtabkey.   "corresp. enti key
    ENDIF.
    cw_sel-viewfield = cw_namtab-viewfield.
    cw_sel-tabix     = sy-tabix.
    cw_sel-operator = 'EQ'.
    cw_sel-and_or = 'AND'.
    CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
      EXPORTING
        value_intern = <cw_value>
        inttype      = cw_namtab-inttype
        datatype     = cw_namtab-datatype
        decimals     = cw_namtab-decimals
        convexit     = cw_namtab-convexit
        sign         = cw_namtab-sign
        outputlen    = cw_namtab-outputlen
        intlen       = cw_namtab-flength
      IMPORTING
        value_extern = cw_sel-value.
    IF cw_sel-value EQ space.
      cw_sel-initial = 'X'.
    ENDIF.
* SW 5.8.98 ..
* folgende MOVE's führen zu unerwünschten impliziten Konvertierungen
* und damit zu Laufzeitfehler
    CLEAR cw_sel-converted.
*   case cw_namtab-inttype.
*     when 'F'. cw_sel-fltp_value = <cw_value>.
*     when 'D'. cw_sel-date_value = <cw_value>.
*     when 'T'. cw_sel-time_value = <cw_value>.
*     when 'P'. cw_sel-pckd_value(cw_namtab-flength) = <cw_value>.
*     when 'N'. cw_sel-numc_value(cw_namtab-flength) = <cw_value>.
*     when 'C'. cw_sel-invd_value(cw_namtab-flength) = <cw_value>.
*     when 'I'. cw_sel-int4_value = <cw_value>.
*     when 'X'.
*       case cw_namtab-datatype.
*         when 'INT1'. cw_sel-int1_value = <cw_value>.
*         when 'INT2'. cw_sel-int2_value = <cw_value>.
*         when 'INT4'. cw_sel-int4_value = <cw_value>.
*         when 'RAW'. cw_sel-raw_value(cw_namtab-flength) = <cw_value>.
*       endcase.
*   endcase.
*   cw_sel-converted = 'X'.                                ".. SW 5.8.98
    APPEND cw_sel TO cw_sellist.
  ENDLOOP.
  DESCRIBE TABLE cw_sellist.
  READ TABLE cw_sellist INTO cw_sel INDEX sy-tfill.
  IF cw_sel-and_or NE space.
    CLEAR cw_sel-and_or. MODIFY cw_sellist INDEX sy-tfill FROM cw_sel.
  ENDIF.
  CALL FUNCTION 'VIEW_FILL_WHERETAB'
    EXPORTING
      tablename               = cw_table
      only_cnds_for_keyflds   = 'X'
    TABLES
      sellist                 = cw_sellist
      wheretab                = vim_wheretab
      x_namtab                = cw_namtab
    EXCEPTIONS
      no_conditions_for_table = 01.
  cw_rc = sy-subrc.
ENDFORM.                               "create_wheretab

*&--------------------------------------------------------------------*
*&      Form  TABLEFRAME                                              *
*&--------------------------------------------------------------------*
* program for function TABLEFRAME_<area>                              *
*&--------------------------------------------------------------------*
FORM  tableframe TABLES header STRUCTURE vimdesc
                        namtab STRUCTURE vimnamtab
                        dbasellist STRUCTURE vimsellist
                        dplsellist STRUCTURE vimsellist
                        exclcuafunct STRUCTURE vimexclfun
                 USING  corrnumber
                        viewaction
                        viewname.                                        "#EC NEEDED

  DATA: enqueue_processed TYPE c, "flag: view enqueued by VIEWFRAME_..
        table_type(11) TYPE c,         "type of table to use
        table_length TYPE i.           "length of current table

*-<<<-------------------------------------------------------------->>>>*
* first of all: determine well-sized internal tables etc.              *
*-<<<-------------------------------------------------------------->>>>*
  READ TABLE header INDEX 1.
  table_length = header-tablen / cl_abap_char_utilities=>charsize + 2.
*  tab lg. + action + mark
  IF header-texttbexst NE space.
    table_length = table_length
     + header-texttablen / cl_abap_char_utilities=>charsize + 1.
* txtb+txtact
  ENDIF.
  IF table_length LE ultra_short_tab.
    MOVE 'ULTRA_SHORT'     TO table_type.
    FREE: extract_vs, total_vs,
          extract_s, total_s,
          extract_m, total_m,
          extract_l, total_l,
          extract_vl, total_vl,
          extract_ul, total_ul.
  ELSEIF table_length LE very_short_tab.
    MOVE 'VERY_SHORT'     TO table_type.
    FREE: extract_us, total_us,
          extract_s, total_s,
          extract_m, total_m,
          extract_l, total_l,
          extract_vl, total_vl,
          extract_ul, total_ul.
  ELSEIF table_length LE short_tab.
    MOVE 'SHORT'     TO table_type.
    FREE: extract_us, total_us,
          extract_vs, total_vs,
          extract_m, total_m,
          extract_l, total_l,
          extract_vl, total_vl,
          extract_ul, total_ul.
  ELSEIF table_length LE middle_tab.
    MOVE 'MIDDLE'    TO table_type.
    FREE: extract_us, total_us,
          extract_vs, total_vs,
          extract_s, total_s,
          extract_l, total_l,
          extract_vl, total_vl,
          extract_ul, total_ul.
  ELSEIF table_length LE long_tab.
    MOVE 'LONG'    TO table_type.
    FREE: extract_us, total_us,
          extract_vs, total_vs,
          extract_s, total_s,
          extract_m, total_m,
          extract_vl, total_vl,
          extract_ul, total_ul.
  ELSEIF table_length LE very_long_tab.
    MOVE 'VERY_LONG'    TO table_type.
    FREE: extract_us, total_us,
          extract_vs, total_vs,
          extract_s, total_s,
          extract_m, total_m,
          extract_l, total_l,
          extract_ul, total_ul.
  ELSEIF table_length LE ultra_long_tab.
    MOVE 'ULTRA_LONG'    TO table_type.
    FREE: extract_us, total_us,
          extract_vs, total_vs,
          extract_s, total_s,
          extract_m, total_m,
          extract_l, total_l,
          extract_vl, total_vl.
  ENDIF.
  maint_mode = viewaction.
  corr_nbr = corrnumber.
*-<<<-------------------------------------------------------------->>>>*
* Entrypoint after changing maintenance mode (show <--> update)        *
*-<<<-------------------------------------------------------------->>>>*
  DO.
*----------------------------------------------------------------------*
* Select data from database                                            *
*----------------------------------------------------------------------*
    PERFORM table_call_function TABLES dbasellist dplsellist
                                header namtab exclcuafunct
                                USING read table_type update_flag.
    CASE sy-subrc.
      WHEN 1.
        RAISE missing_corr_number.
    ENDCASE.
*-<<<-------------------------------------------------------------->>>>*
* Entrypoint after saving data into database                           *
* Entrypoint after refreshing selected entries from database           *
*-<<<-------------------------------------------------------------->>>>*
    DO.
*----------------------------------------------------------------------*
* Edit data                                                            *
*----------------------------------------------------------------------*
      DO.
        PERFORM table_call_function
                             TABLES dbasellist dplsellist
                                    header namtab exclcuafunct
                             USING edit table_type <status>-upd_flag.
        CASE sy-subrc.
          WHEN 1.
            IF maint_mode EQ transportieren AND viewaction EQ aendern.
              MOVE viewaction TO maint_mode.
            ELSE.
              RAISE missing_corr_number.
            ENDIF.
          WHEN OTHERS.
            EXIT.
        ENDCASE.
      ENDDO.
*----------------------------------------------------------------------*
*  Handle usercommands...                                              *
*  ...at first handle commands which could cause loss of data          *
*----------------------------------------------------------------------*
      IF function EQ back.
        function = end.
      ENDIF.
      IF ( function EQ switch_to_show_mode OR
           function EQ get_another_view    OR
           function EQ switch_transp_to_upd_mode OR
           function EQ end ) AND
         <status>-upd_flag NE space.
        PERFORM beenden.
        CASE sy-subrc.
          WHEN 0.
            PERFORM table_call_function
                         TABLES dbasellist dplsellist
                                header namtab exclcuafunct
                         USING save table_type <status>-upd_flag.
            CASE sy-subrc.
              WHEN 0.
                IF <status>-upd_flag EQ space. EXIT. ENDIF.
              WHEN 1.
                RAISE missing_corr_number.
              WHEN 3.
            ENDCASE.
          WHEN 8.
            EXIT.
          WHEN 12.
        ENDCASE.
*----------------------------------------------------------------------*
*  ...2nd: transport request                                           *
*----------------------------------------------------------------------*
      ELSEIF function EQ transport.
        IF <status>-upd_flag NE space.
          PERFORM transportieren.
          CASE sy-subrc.
            WHEN 0.
              PERFORM table_call_function
                              TABLES dbasellist dplsellist
                                     header namtab exclcuafunct
                              USING save table_type <status>-upd_flag.
              CASE sy-subrc.
                WHEN 0.
                  maint_mode = transportieren.
                WHEN 1.
                  RAISE missing_corr_number.
                WHEN 3.
              ENDCASE.
            WHEN 8.
              EXIT.
            WHEN 12.
          ENDCASE.
        ELSE.
          maint_mode = transportieren.
        ENDIF.
*----------------------------------------------------------------------*
*  ...now reset or save requests                                       *
*----------------------------------------------------------------------*
      ELSEIF function EQ reset_list  OR
             function EQ reset_entry OR
             function EQ save.
*----------------------------------------------------------------------*
*  Refresh selected entries from database or save data into database   *
*----------------------------------------------------------------------*
        PERFORM table_call_function
                          TABLES dbasellist dplsellist
                                 header namtab exclcuafunct
                          USING function table_type <status>-upd_flag.
        CASE sy-subrc.
          WHEN 1.
            RAISE missing_corr_number.
          WHEN 3.
        ENDCASE.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
*----------------------------------------------------------------------*
*  ...now other commands...                                            *
*----------------------------------------------------------------------*
    CASE function.
      WHEN switch_to_show_mode.
*   change maintenance mode from update to show
        PERFORM enqueue USING 'D' header-frm_af_enq. "dequeue view
        CLEAR enqueue_processed.
        maint_mode = anzeigen.
      WHEN switch_to_update_mode.
*     change maintenance mode from show to update
        PERFORM enqueue USING 'E' header-frm_af_enq.  "enqueue view
        IF sy-subrc EQ 0.
          MOVE 'X' TO enqueue_processed.
          maint_mode = aendern.
        ENDIF.
      WHEN switch_transp_to_upd_mode.
*     change maintenance mode from transport to update
        maint_mode = aendern.
      WHEN transport.
*     change maintenance mode from update to transport
        maint_mode = transportieren.
      WHEN OTHERS.
        IF enqueue_processed NE space.
          PERFORM enqueue USING 'D' header-frm_af_enq."dequeue view
        ENDIF.
        PERFORM before_leaving_frame_function
                                      USING header-frm_bf_end.
        EXIT.
    ENDCASE.
  ENDDO.
ENDFORM.                                                    "

*&--------------------------------------------------------------------*
*&      Form TABLEPROC                                                *
*&--------------------------------------------------------------------*
* program for function TABLEPROC_<area>                               *
*&--------------------------------------------------------------------*
FORM  tableproc.
*----------------------------------------------------------------------*
* Initialization: set field-symbols etc.                               *
*----------------------------------------------------------------------*
  IF last_view_info NE view_name.
    PERFORM initialisieren.
  ENDIF.
  PERFORM justify_action_mode.
  MOVE: view_action TO maint_mode,
        corr_number TO corr_nbr.

*----------------------------------------------------------------------*
* Get data from database                                               *
*----------------------------------------------------------------------*
  IF fcode EQ read OR fcode EQ read_and_edit.
    PERFORM prepare_read_request.
    IF x_header-frm_rp_get NE space.
      PERFORM (x_header-frm_rp_get) IN PROGRAM (sy-repid).
    ELSE.
      PERFORM table_get_data.
    ENDIF.
    IF fcode EQ read_and_edit. fcode = edit. ENDIF.
  ENDIF.

  CASE fcode.
    WHEN  edit.                        " Edit read data
      PERFORM call_dynpro.
      PERFORM check_upd.
*....................................................................*

    WHEN save.                         " Write data into database
      PERFORM prepare_saving.
      IF <status>-upd_flag NE space.
        IF x_header-frm_rp_upd NE space.
          PERFORM (x_header-frm_rp_upd) IN PROGRAM.
        ELSE.
          IF sy-subrc EQ 0.
            PERFORM table_db_upd.
          ENDIF.
        ENDIF.
        PERFORM after_saving.
      ENDIF.
*....................................................................*

    WHEN reset_list.     " Refresh all marked entries of EXTRACT from db
      PERFORM reset_entries USING list_bild.
*....................................................................*

    WHEN reset_entry.               " Refresh single entry from database
      PERFORM reset_entries USING detail_bild.
*.......................................................................
  ENDCASE.
  MOVE: <status>-upd_flag TO update_required,
        function TO ucomm.
ENDFORM.                               "tableproc

*&--------------------------------------------------------------------*
*&      FORM  REPLACE_FORBIDDEN_CHARS                                 *
*&--------------------------------------------------------------------*
* replace forbidden characters with internal code into NAME           *
*---------------------------------------------------------------------*
* ---> NAME - name to correct                                         *
* ---> FORBIDDEN_CHARS - chars which must be replaced                 *
* <--- NAME - corrected name                                          *
*&--------------------------------------------------------------------*
FORM  replace_forbidden_chars USING value(forbidden_chars) name.
  FIELD-SYMBOLS: <code>.
  DATA: suspect_char(1) TYPE c, code(2) TYPE c.

  DO.
    IF name CA forbidden_chars.
      ASSIGN name+sy-fdpos(1)  TO <code>.
      MOVE <code> TO suspect_char.
      ASSIGN <code> TO <code> TYPE 'X'.
      MOVE <code> TO code.
      REPLACE suspect_char WITH code INTO name.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                               "replace_forbidden_chars
*&---------------------------------------------------------------------*
*&      Form  vim_get_text_keyflds
*&---------------------------------------------------------------------*
*       inserts all key field names of a texttable into a table
*----------------------------------------------------------------------*
*      -->P_TEXTTABNAME   text table name
*      <--P_TEXT_KEYFLDS  table of keyfields
*----------------------------------------------------------------------*
FORM vim_get_text_keyflds USING p_texttabname TYPE tabname
                         CHANGING p_text_keyflds TYPE vim_flds_tab_type.

  STATICS: texttabname_save TYPE tabname,
           text_keyflds_save TYPE vim_flds_tab_type.

  FIELD-SYMBOLS: <namtab> TYPE vimnamtab.

  REFRESH p_text_keyflds.
  IF texttabname_save = p_texttabname.
    APPEND LINES OF text_keyflds_save TO p_text_keyflds.
  ELSE.
    texttabname_save = p_texttabname.
    REFRESH text_keyflds_save.
    LOOP AT x_namtab ASSIGNING <namtab> WHERE texttabfld NE space
                       AND keyflag NE space.
      APPEND <namtab>-viewfield TO p_text_keyflds.
    ENDLOOP.
    APPEND LINES OF p_text_keyflds TO text_keyflds_save.
  ENDIF.
ENDFORM.                               " vim_get_text_keyflds

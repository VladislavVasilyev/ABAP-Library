*&--------------------------------------------------------------------*
*&      Form  EDIT_VIEW_ENTRY                                         *
*&--------------------------------------------------------------------*
*       edit entry in TOTAL/EXTRACT due to foreign request            *
*---------------------------------------------------------------------*
* ENTRY  ---> entry to edit                                           *
* ACTION ---> action: UPD - add/update, DEL - delete, UDL - undelete  *
*             IGN - mark entry as to ignore, MRK - mark/unmark entry  *
* SY_SUBRC -> return code: 0 - all right, others: failure             *
* EXT    ---> table containing selected view entries                  *
* TOT    ---> table containing all view entries                       *
* HEADER ---> table containing header information of current view     *
* NAMTAB ---> table containing information about current viewfields   *
* SELLIST --> table containing select options                         *
*---------------------------------------------------------------------*
FORM edit_view_entry TABLES ext tot
                            header  STRUCTURE vimdesc
                            namtab  STRUCTURE vimnamtab
                            sellist STRUCTURE vimsellist
                     USING value(entry) value(action).
  DATA: state_vect_name(37) TYPE c,
        rc LIKE sy-subrc, pos LIKE sy-fdpos,
        texttablename(31) TYPE c VALUE '*          ', mmark(1) TYPE c,
        tab_rc LIKE sy-subrc, tab_ix LIKE sy-tabix,
        dummy_tab LIKE vimexclfun OCCURS 1, name(20) TYPE c.       "#EC NEEDED
  FIELD-SYMBOLS: <tot_x> TYPE x, <ext_x> TYPE x, <ent_x> TYPE x,
                 <viewkey> TYPE x, <act> TYPE c, <xact> TYPE c,
                 <mrk> TYPE c, <xmrk> TYPE c,
                 <txt_act> TYPE c,
                 <tot_struc> TYPE ANY, <ent_struc> TYPE ANY,
                 <tot_txt> TYPE x, <ent_txt> TYPE x, <ent_txt2> TYPE x,
                 <tot_txt_struc> TYPE ANY, <txt_init> TYPE ANY.

  READ TABLE header INDEX 1.
  pos = header-after_tabc.
*  MOVE HEADER-TABLEN TO POS.
  ASSIGN: tot TO <tot_x> CASTING, ext TO <ext_x> CASTING,
          entry TO <ent_x> CASTING,
          <tot_x> TO <tot_struc> CASTING TYPE (header-maintview),
          <ent_x> TO <ent_struc> CASTING TYPE (header-maintview).
  IF header-bastab NE space AND header-texttbexst NE space.
* tab+txttb
    ADD header-aft_txttbc TO pos.
    MOVE header-texttab TO texttablename+1.
    ASSIGN: <tot_x>+header-after_tabc(header-texttablen) TO <tot_txt>,
            <ent_x>+header-after_tabc(header-texttablen) TO <ent_txt>,
            <tot_txt> TO <tot_txt_struc> CASTING TYPE (header-texttab),
            (texttablename) TO <txt_init>.
*    ASSIGN: TOT+HEADER-TABLEN(HEADER-TEXTTABLEN) TO <TOT_TXT>,
*            ENTRY+HEADER-TABLEN(HEADER-TEXTTABLEN) TO <ENT_TXT>,
*            (TEXTTABLENAME) TO <TXT_INIT>.
  ENDIF.
  ASSIGN: <ent_x>(header-keylen) TO <viewkey>,
          <tot_x>+pos(cl_abap_char_utilities=>charsize)
           TO <act> CASTING,
          <ext_x>+pos(cl_abap_char_utilities=>charsize)
           TO <xact> CASTING.
  ADD cl_abap_char_utilities=>charsize TO pos.
  ASSIGN: <tot_x>+pos(cl_abap_char_utilities=>charsize)
           TO <mrk> CASTING,
          <ext_x>+pos(cl_abap_char_utilities=>charsize)
           TO <xmrk> CASTING.
  IF header-bastab NE space AND header-texttbexst NE space."tab+txttb
    ADD cl_abap_char_utilities=>charsize TO pos.
    ASSIGN <tot_x>+pos(cl_abap_char_utilities=>charsize)
     TO <txt_act> CASTING.
  ENDIF.
*  ASSIGN: ENTRY(HEADER-KEYLEN) TO <VIEWKEY>,
*          TOT+POS(1) TO <ACT>.
*  ADD 1 TO POS.
*  ASSIGN TOT+POS(1) TO <MRK>.
*  IF HEADER-BASTAB NE SPACE AND HEADER-TEXTTBEXST NE SPACE."tab+txttb
*    ADD 1 TO POS.
*    ASSIGN TOT+POS(1) TO <TXT_ACT>.
*    SUBTRACT 1 FROM POS.
*  ENDIF.
  IF header-viewname NE last_ext_modif_view.
    MOVE state_vect_prefix TO state_vect_name.
    WRITE header-maintview TO state_vect_name+state_vect_prefix_length.
    ASSIGN (state_vect_name) TO <state>.
    MOVE header-viewname TO last_ext_modif_view.
  ENDIF.
  READ TABLE tot WITH KEY <viewkey> BINARY SEARCH.          "#EC *
  tab_rc = sy-subrc. tab_ix = sy-tabix.
  IF sy-subrc EQ 0.                    " entry found in TOT
    CASE action.
      WHEN 'DEL'.
        CASE <act>.
          WHEN neuer_eintrag.
            <act> = neuer_geloescht.
          WHEN original.
            <act> = geloescht.
          WHEN aendern.
            <act> = update_geloescht.
        ENDCASE.
        IF header-bastab NE space AND header-texttbexst NE space.
          CASE <txt_act>.
            WHEN neuer_eintrag.
              <txt_act>            = neuer_geloescht.
            WHEN original.
              IF <tot_txt_struc> NE <txt_init>.
                <txt_act>             = geloescht.
              ENDIF.
            WHEN aendern.
              <txt_act>             = update_geloescht.
          ENDCASE.
        ENDIF.
        mmark = <mrk>.
        IF <mrk> EQ markiert.
          <mrk> = nicht_markiert. SUBTRACT 1 FROM <state>-mk_to.
        ENDIF.
        MODIFY tot INDEX sy-tabix.
        READ TABLE ext WITH KEY <viewkey>.                  "#EC *
        IF sy-subrc EQ 0.
          IF mmark EQ markiert.
            SUBTRACT 1 FROM <state>-mk_xt.
          ENDIF.
          DELETE ext INDEX sy-tabix.
          SUBTRACT 1 FROM <state>-maxlines.
        ENDIF.
      WHEN 'UPD'.
        IF header-bastab NE space AND header-texttbexst NE space.
          IF <tot_txt> NE <ent_txt>.
            IF <tot_txt_struc> EQ <txt_init>.
              <txt_act> = neuer_eintrag.
            ELSE.
              IF <txt_act> EQ original.
                <txt_act> = aendern.
              ENDIF.
            ENDIF.
            MOVE <ent_txt> TO <tot_txt>.
          ENDIF.
        ENDIF.
        MOVE <ent_struc> TO <tot_struc>.
        IF <act> EQ original.
          <act> = aendern.
        ENDIF.
        MODIFY tot INDEX sy-tabix.
        READ TABLE ext WITH KEY <viewkey>.                  "#EC *
        IF sy-subrc EQ 0.
          MOVE tot TO ext.
          MODIFY ext INDEX sy-tabix.
        ENDIF.
      WHEN 'UDL'.
        CASE <act>.
          WHEN neuer_geloescht.
            <act> = neuer_eintrag.
          WHEN geloescht.
            <act> = original.
          WHEN update_geloescht.
            <act> = aendern.
          WHEN OTHERS.
            rc = 8.
        ENDCASE.
        IF rc EQ 0.
          IF header-bastab NE space AND header-texttbexst NE space.
            CASE <txt_act>.
              WHEN neuer_geloescht.
                <txt_act>         = neuer_eintrag.
              WHEN geloescht.
                <txt_act>         = original.
              WHEN update_geloescht.
                <txt_act>         = aendern.
            ENDCASE.
          ENDIF.
          MODIFY tot INDEX sy-tabix.
          READ TABLE ext WITH KEY <viewkey>.                "#EC *
          IF sy-subrc EQ 0.
            IF <state>-selected EQ geloescht.
              DELETE ext INDEX sy-tabix.
            ELSE.
              <xmrk> = <mrk>.
              <xact> = <act>.
              MODIFY ext INDEX sy-tabix.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN 'IGN'.
        IF <mrk> EQ markiert.
          MOVE uebergehen TO <mrk>.
          MODIFY tot INDEX sy-tabix.
          READ TABLE ext WITH KEY <viewkey>.                "#EC *
          IF sy-subrc EQ 0.
            <xmrk> = <mrk>.
            MODIFY ext INDEX sy-tabix.
          ENDIF.
        ENDIF.
        rc = 1.
      WHEN 'MRK'.
        IF <mrk> EQ markiert.
          MOVE nicht_markiert TO <mrk>.
        ELSE.
          MOVE markiert TO <mrk>.
        ENDIF.
        MODIFY tot INDEX sy-tabix.
        IF <mrk> EQ markiert.
          ADD 1 TO <state>-mk_to.
        ELSE.
          SUBTRACT 1 FROM <state>-mk_to.
        ENDIF.
        READ TABLE ext WITH KEY <viewkey>.                  "#EC *
        IF sy-subrc EQ 0.
          <xmrk> = <mrk>.
          MODIFY ext INDEX sy-tabix.
          IF <mrk> EQ markiert.
            ADD 1 TO <state>-mk_xt.
          ELSE.
            SUBTRACT 1 FROM <state>-mk_xt.
          ENDIF.
        ENDIF.
        rc = 1.
    ENDCASE.
  ELSE.                                "entry NOT found in TOT
    CLEAR sy-subrc.
    IF action NE 'UPD'.
      rc = 8.
    ELSE.
      IF header-selection NE space.
        IF header-bastab <> space AND header-texttbexst <> space.
          ASSIGN <ent_txt> TO <ent_txt2>.
        ELSE.
          ASSIGN <ent_x> TO <ent_txt2>.
        ENDIF.
        CALL FUNCTION 'TABLE_RANGE_CHECK'
          EXPORTING
            tabname                   = header-maintview
            entry                     = entry
            entry_text                = <ent_txt2>
            ddic                      = 'J'
            key                       = 'J'
            ignore_blank_subsetfields = 'N'
          TABLES
            x_namtab                  = namtab
            x_header                  = header
            sellist                   = sellist
          EXCEPTIONS
            entry_not_fits            = 8.
      ENDIF.
      IF sy-subrc EQ 0.
        MOVE <ent_struc> TO <tot_struc>.
        <act> = neuer_eintrag.
        <mrk> = nicht_markiert.
        IF header-bastab NE space AND header-texttbexst NE space.
          <tot_txt> = <ent_txt>.
          IF <tot_txt_struc> NE <txt_init>.
            <txt_act> = neuer_eintrag.
          ELSE.
            <txt_act> = original.
          ENDIF.
        ENDIF.
        CASE tab_rc.
          WHEN 4.
            INSERT tot INDEX tab_ix.
          WHEN 8.
            APPEND tot.
        ENDCASE.
      ELSE.
        rc = sy-subrc.
      ENDIF.
    ENDIF.
  ENDIF.
  IF rc EQ 0.
    MOVE 'X' TO <state>-upd_flag.
  ENDIF.
  sy-subrc = ( rc DIV 8 ) * 8.
ENDFORM.                               " EDIT_VIEW_ENTRY

*---------------------------------------------------------------------*
*       FORM INIT_SUBSET_KEYFIELDS                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM init_subset_keyfields.
  DATA: all_flds_blank TYPE c VALUE 'X', state_init TYPE c.
  FIELD-SYMBOLS: <key> type x.
  ASSIGN <initial_x>(x_header-keylen) TO <key>.
  clear <table1_wa>.
  MOVE <key> TO <f1_wax>.
  IF <status>-sbsid_rcvd NE space.
    CALL FUNCTION 'VIEW_INIT_SUBST_KEYFLDS'
         EXPORTING
              visk_tabname         = x_header-maintview
              workarea_in          = <initial>
         IMPORTING
              workarea_out         = <initial>
              all_fields_blank     = all_flds_blank
              state_init_necessary = state_init
         TABLES
              sellist              = dba_sellist
              x_namtab             = x_namtab.
  ELSE.
    CALL FUNCTION 'VIEW_INIT_SUBST_KEYFLDS'
         EXPORTING
              visk_tabname         = x_header-maintview
              workarea_in          = <initial>
         IMPORTING
              workarea_out         = <initial>
              all_fields_blank     = all_flds_blank
              state_init_necessary = state_init
         TABLES
              sellist              = dpl_sellist
              x_namtab             = x_namtab.
    IF all_flds_blank NE space.
      RAISE no_value_for_subset_ident.
    ENDIF.
    IF <key> NE <f1_wax>.
      MOVE 'X' TO state_init.
    ELSE.  "nicht-Key Subsetfelder, für die in ZP19 Keyflag gesetzt
      LOOP AT x_namtab where keyflag  <> SPACE  AND
                             readonly =  subset AND
                             position >= x_header-keylen.
        MOVE 'X' TO state_init. EXIT.
      ENDLOOP.
    ENDIF.
    IF state_init NE space.
      CLEAR: <status>-maxlines,
             <status>-cur_field,
             <status>-cur_offset.
      MOVE: 1 TO <status>-cur_line,
            1 TO <status>-firstline,
            maint_mode TO <status>-st_action,
            nicht_geloescht TO <status>-st_delete,
            list_bild TO <status>-st_mode.
      PERFORM set_status_nokeyselcnds.
    ELSE.
* further selection criteria?
      LOOP AT dpl_sellist TRANSPORTING NO FIELDS
                          WHERE ddic EQ space OR ( operator EQ 'GE' OR
                                                   operator EQ 'GT' OR
                                                   operator EQ 'LE' OR
                                                   operator EQ 'LT' ).
        EXIT.
      ENDLOOP.
      IF sy-subrc <> 0 and <status>-maxlines <> 0.
        <status>-selcd_rcvd = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.

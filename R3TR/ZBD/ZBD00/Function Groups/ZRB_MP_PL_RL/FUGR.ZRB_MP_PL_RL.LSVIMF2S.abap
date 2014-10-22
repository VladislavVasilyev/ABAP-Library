*---------------------------------------------------------------------*
*       LOGICAL_DELETE_FROM_TOTAL                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM logical_delete_from_total USING value(cur_index) TYPE i.
  CASE <action>.
    WHEN neuer_eintrag.
      <action>         = neuer_geloescht.
    WHEN original.
      <action>         = geloescht.
    WHEN aendern.
      <action>         = update_geloescht.
  ENDCASE.
*  perform vim_bc_logs_maintain using geloescht
*                                     x_header
*                               changing vim_bc_entry_list.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    CASE <action_text>.
      WHEN neuer_eintrag.
        <action_text>         = neuer_geloescht.
      WHEN original.
        IF <vim_xtotal_text> NE <text_initial_x>.
*        IF <total_text> NE <text_initial>.
          <action_text>         = geloescht.
        ELSE.
          PERFORM (vim_frm_fill_textkey) IN PROGRAM (sy-repid)
                                       USING <vim_total_struc>
                                             <vim_tot_txt_struc>.
* Unicode: Form FILL_TEXTTAB_KEY_UC instead of FILL_TEXTTAB_KEY_UC
*                                       USING <vim_total_key>
*                                             <total_text>.
          <action_text>         = dummy_geloescht. "always del texttbent
        ENDIF.
      WHEN aendern.
        <action_text>         = update_geloescht.
    ENDCASE.
  ENDIF.
  <mark>       = nicht_markiert.
  MODIFY total INDEX cur_index.
ENDFORM.                               "logical_delete_from_total

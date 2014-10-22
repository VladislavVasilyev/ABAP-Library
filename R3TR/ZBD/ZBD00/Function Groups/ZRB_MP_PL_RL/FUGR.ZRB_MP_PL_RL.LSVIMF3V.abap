*---------------------------------------------------------------------*
*       FORM SET_TITLE                                                *
*---------------------------------------------------------------------*
* Titel setzen: entweder allgemein oder angegeb. Programm             *
*---------------------------------------------------------------------*
FORM set_title USING st_title st_title_text.
  DATA: st_state LIKE sy-pfkey.
  CASE x_header-gui_prog.
    WHEN master_fpool.
      MOVE st_title TO st_state.
      CALL FUNCTION 'VIEW_SET_PF_STATUS'
        EXPORTING
          status         = st_state
          title          = 'X'
          title_text     = st_title_text
          objimp         = x_header-importable
        TABLES
          excl_cua_funct = excl_cua_funct.
    WHEN sy-repid.
      SET TITLEBAR st_title WITH st_title_text.
    WHEN OTHERS.
      RAISE wrong_gui_programm.
  ENDCASE.
ENDFORM.                    "SET_TITLE

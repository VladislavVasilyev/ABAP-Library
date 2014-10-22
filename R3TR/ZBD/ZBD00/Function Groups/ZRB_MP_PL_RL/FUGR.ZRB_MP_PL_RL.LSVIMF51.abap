*----------------------------------------------------------------------*
*   INCLUDE LSVIMF51                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VIM_ADD_IMG_NOTICES_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DYNPRO  Dynpro number
*----------------------------------------------------------------------*
FORM vim_add_img_notices_pbo USING    value(p_dynpro) TYPE list_scr.

  DATA: progname LIKE sy-repid, exit, dynpro TYPE sydynnr.  "#EC *

  CHECK vim_special_mode <> vim_upgrade AND vim_import_profile = space.
  progname = sy-repid.
  dynpro = p_dynpro.
  CALL FUNCTION 'SPROJECT_CONTROL_PBO'
       EXPORTING
            repid = progname
            dynnr = dynpro.
ENDFORM.                               " VIM_ADD_IMG_NOTICES_PBO

*&---------------------------------------------------------------------*
*&      Form  VIM_ADD_IMG_NOTICES_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MODE   text
*      <--P_EXIT_OK  text
*----------------------------------------------------------------------*
FORM vim_add_img_notices_pai USING    p_mode TYPE char1
                             CHANGING exit_ok TYPE char1.

  DATA: leave TYPE char1, save TYPE char1.

  CHECK vim_special_mode <> vim_upgrade AND vim_import_profile = space.
  CASE p_mode.
    WHEN 'S'.                          "Save notices
      save = 'X'.
    WHEN 'E'.                          "Exit and eventually save changes
      leave = 'X'.
  ENDCASE.
  CALL FUNCTION 'SPROJECT_CONTROL_PAI'
       EXPORTING
            i_exit    = leave
            save_note = save
       IMPORTING
            e_exit    = exit_ok.
ENDFORM.                               " VIM_ADD_IMG_NOTICES_PAI

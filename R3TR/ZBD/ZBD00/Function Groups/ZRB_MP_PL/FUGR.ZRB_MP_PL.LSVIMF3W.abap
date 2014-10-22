*---------------------------------------------------------------------*
*       FORM SET_PF_STATUS                                            *
*---------------------------------------------------------------------*
* PF-Status setzen: entweder allgemein oder angegeb. Programm         *
*---------------------------------------------------------------------*
FORM set_pf_status USING value(sps_status).
  DATA: sps_state LIKE sy-pfkey, sps_stat TYPE state_vector.
  CASE x_header-gui_prog.
    WHEN master_fpool.
      MOVE sps_status TO sps_state.
      CALL FUNCTION 'VIEW_SET_PF_STATUS'
        EXPORTING
          status         = sps_state
          objimp         = x_header-importable
        TABLES
          excl_cua_funct = excl_cua_funct.
    WHEN sy-repid.
      MOVE sps_status TO sps_stat.
      IF sps_stat-action EQ anzeigen OR
         sps_stat-action EQ transportieren OR
         ( sy-mandt EQ '000' AND vim_system_type NE 'SAP' ) OR
         x_header-importable = vim_not_importable.
        vim_comp_menue_text = svim_text_045.
      ELSE.
        vim_comp_menue_text = svim_text_046.
      ENDIF.
      vim_pr_stat_txt_ch = svim_text_prb.
      vim_pr_stat_txt_ta = svim_text_prc.
      vim_pr_stat_txt_me = svim_text_pri.
      vim_pr_stat_txt_or = svim_text_prj.
      SET PF-STATUS sps_status EXCLUDING excl_cua_funct.
    WHEN OTHERS.
      RAISE wrong_gui_programm.                             "#EC *
  ENDCASE.
ENDFORM.                    "SET_PF_STATUS

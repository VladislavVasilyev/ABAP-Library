METHOD GET_CV_LOGIC.

  DATA: ls_filter_tab         TYPE LINE OF ujd_th_dim_mem,
        lt_k_cv               TYPE ujk_t_cv,  " initial means to deal with the whole cube
        ls_k_cv               TYPE ujk_s_cv,
        l_member              TYPE uj_dim_member.

  FIELD-SYMBOLS:
                 <ls_k_cv>    TYPE ujk_s_cv.

  LOOP AT it_filter_tab INTO ls_filter_tab.
    CLEAR l_member.
    READ TABLE lt_k_cv WITH TABLE KEY dim_upper_case = ls_filter_tab-dimname ASSIGNING <ls_k_cv>. "#EC *
    IF sy-subrc = 0.
      l_member = ls_filter_tab-memname.
      INSERT l_member INTO TABLE <ls_k_cv>-member.
    ELSE.
      CLEAR ls_k_cv.
      ls_k_cv-dimension = ls_filter_tab-dimname.
      TRANSLATE ls_filter_tab-dimname TO UPPER CASE. "#EC TRANSLANG
      ls_k_cv-dim_upper_case = ls_filter_tab-dimname.
      ls_k_cv-user_specified = abap_true.
      l_member = ls_filter_tab-memname.
      INSERT l_member INTO TABLE ls_k_cv-member.
      INSERT ls_k_cv INTO TABLE lt_k_cv.
    ENDIF.
  ENDLOOP.

  et_k_cv = lt_k_cv.

ENDMETHOD.

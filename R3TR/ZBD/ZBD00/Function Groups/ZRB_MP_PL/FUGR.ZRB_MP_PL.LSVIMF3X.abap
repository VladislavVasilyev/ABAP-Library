*---------------------------------------------------------------------*
*       FORM EXCLUDE_CUA_FUNCTIONS                                    *
*---------------------------------------------------------------------*
* ggf. Funktionen ausschließen                                        *
*---------------------------------------------------------------------*
FORM exclude_cua_functions.
  MOVE 'SLCT' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  IF x_header-delmdtflag EQ space.
    MOVE 'DELM' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    MOVE 'EXPA' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    TRANSLATE x_header-existency USING 'MU'.
    MODIFY x_header INDEX 1.
  ELSEIF vim_begdate_is_ro NE space.
    MOVE 'DELM' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    MODIFY x_header INDEX 1.
  ENDIF.
  CASE x_header-existency.
    WHEN 'U'.                          "update only
      MOVE 'NEWL' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      MOVE 'ALNW' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      MOVE 'ALOE' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      MOVE 'DELE' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      MOVE 'KOPE' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      MOVE 'DELM' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    WHEN 'M'.                          "update only for main key
      MOVE 'NEWL' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    WHEN 'R'.                          "read only
      MOVE 'AEND' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ENDCASE.
  IF x_header-clidep EQ space OR sy-mandt EQ '000'.
    MOVE 'COMP' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    IF x_header-clidep EQ space.
      MOVE 'CMPO' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    ENDIF.
  ENDIF.
  IF x_header-flag NE space AND x_header-cursetting EQ 'Y' AND
     NOT ( x_header-frm_e071 NE space OR x_header-frm_e071ks NE space OR
           x_header-frm_e071ka NE space ).
    MOVE 'TRSP' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ENDIF.
  IF x_header-adrnbrflag EQ space.
    MOVE 'ADDR' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ELSE.
    LOOP AT excl_cua_funct WHERE function EQ 'ADDR'.
      DELETE excl_cua_funct.
    ENDLOOP.
  ENDIF.
  IF x_header-scrfrmflag EQ space.
    MOVE 'SCRF' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ELSE.
    LOOP AT excl_cua_funct WHERE function EQ 'SCRF'.
      DELETE excl_cua_funct.
    ENDLOOP.
  ENDIF.
  IF x_header-texttbexst EQ space.     "SW Texttransl
    MOVE 'LANG' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    MOVE 'TEXT' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ENDIF.
  IF vim_coming_from_img = 'N'.        "UF profiles
* profiles can't be activated
    MOVE 'GPRF' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    MOVE 'UPRF' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ELSE.
    IF maint_mode = anzeigen.
* profile activating not allowed
      MOVE 'UPRF' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    ELSE.
      DELETE excl_cua_funct WHERE function = 'UPRF'.
    ENDIF.
  ENDIF.
  IF <status>-bcfixnochg = space.
    MOVE 'BCCH' TO excl_cua_funct-function. COLLECT excl_cua_funct.
*   MOVE 'BCSH' TO excl_cua_funct-function. COLLECT excl_cua_funct.
  ELSE.
    DELETE excl_cua_funct WHERE function = 'BCCH'.
*    DELETE excl_cua_funct WHERE function = 'BCSH'.   "HCG HW681286
  ENDIF.
ENDFORM.                    "EXCLUDE_CUA_FUNCTIONS

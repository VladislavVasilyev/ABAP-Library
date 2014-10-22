*----------------------------------------------------------------------*
***INCLUDE LSVIMF5B .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_LIST_BEFORE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_list_before_alv CHANGING rc LIKE sy-subrc.

  DATA:          counter TYPE i, index type i,
                 variant LIKE disvariant,
                 fcat_var TYPE slis_t_fieldcat_alv.
  FIELD-SYMBOLS: <fcat> TYPE slis_fieldcat_alv.
  CONSTANTS:     alv_maxcols TYPE i VALUE 99.

  CLEAR: counter, rc.
  LOOP AT vim_alv_fcat TRANSPORTING NO FIELDS WHERE no_out <> 'X'.
    ADD 1 TO counter.
  ENDLOOP.
  CHECK counter > alv_maxcols.
* suitable standard variant defined?
  CONCATENATE x_header-viewname sy-repid INTO variant-report.
  CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
       EXPORTING
            i_dialog            = space
            i_user_specific     = 'X'
            i_default           = 'X'  "vim_var_default
*         I_TABNAME_HEADER    =
*         I_TABNAME_ITEM      =
            it_default_fieldcat = vim_alv_fcat
            i_layout            = vim_alv_layout
       IMPORTING
*         E_EXIT              =
            et_fieldcat         = fcat_var
*         ET_SORT             =
*         ET_FILTER           =
            es_layout           = vim_alv_layout
       CHANGING
            cs_variant          = variant
       EXCEPTIONS
            wrong_input         = 1
            fc_not_complete     = 2
            not_found           = 3
            program_error       = 4
            OTHERS              = 5.
  IF sy-subrc = 0 AND NOT variant-variant IS INITIAL.
    CLEAR: counter.
    LOOP AT fcat_var TRANSPORTING NO FIELDS WHERE no_out <> 'X'.
      ADD 1 TO counter.
    ENDLOOP.
    CHECK counter > alv_maxcols.
  ENDIF.
* no variant with less than 99 columns exists
*  WHILE counter > alv_maxcols.
*    MESSAGE i807(sv) WITH counter.
**    Bitte wählen Sie max. 99 Felder für die Liste aus.
*    CALL FUNCTION 'REUSE_ALV_VARIANT_MAINTAIN'
*         EXPORTING
**         I_TABNAME_HEADER  =
**         I_TABNAME_ITEM    =
*              i_save            = vim_var_save
**         I_POPUP           = 'X'
*              is_layout         = vim_alv_layout
**         IT_SPECIAL_GROUPS =
**         IT_SORT           =
**    IMPORTING
**         E_SAVE            =
*         CHANGING
*              ct_fieldcat       = vim_alv_fcat
*         EXCEPTIONS
*              no_change         = 1
**         PROGRAM_ERROR     = 2
*              OTHERS            = 3.
*    rc = sy-subrc.
*    IF rc <> 0. EXIT. ENDIF.
*    CLEAR counter.
*    LOOP AT vim_alv_fcat TRANSPORTING NO FIELDS WHERE no_out <> 'X'.
*      ADD 1 TO counter.
*    ENDLOOP.
**    check counter < alv_maxcols.
** field catalogue changed => rearrange value tab
*>>>>Complete field catalogue needs to be rearranged here: too lavish
*>>>>for this rare case. Let's try an easier attempt at first.
*  ENDWHILE.
  MESSAGE i808(sv) with COUNTER.
*   Es können nicht alle Spalten der Tabelle auf der Liste angezeigt wer
  index = alv_maxcols + 1.
  LOOP AT vim_alv_fcat ASSIGNING <fcat> FROM index.
    <fcat>-no_out = 'X'.
  ENDLOOP.
ENDFORM.                               " CHECK_LIST_BEFORE_ALV

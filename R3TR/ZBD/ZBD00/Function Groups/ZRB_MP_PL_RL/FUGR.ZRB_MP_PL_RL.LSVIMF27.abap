*---------------------------------------------------------------------*
*       FORM ENQUEUE                                                  *
*---------------------------------------------------------------------*
* enqueue view                                                        *
*---------------------------------------------------------------------*
* VALUE(E_ACT) --> action: E -> enqueue, D -> dequeue                 *
* VALUE(EXIT_FORM) ---> name of exit form to process after enqueue    *
*---------------------------------------------------------------------*
FORM enqueue USING value(e_act) value(exit_form).
*----------------------------------------------------------------------*
*      enqueue view
*----------------------------------------------------------------------*
  CALL FUNCTION 'VIEW_ENQUEUE'
       EXPORTING
            view_name        = vim_view_name
            action           = e_act
            enqueue_mode     = 'E'
            enqueue_range    = vim_enqueue_range
       TABLES
            sellist          = <vim_sellist>
    EXCEPTIONS                                              "#EC *
            foreign_lock     = 1
            system_failure   = 2
            table_not_found  = 5
            client_reference = 7.

  DATA: rc LIKE sy-subrc.

  CASE sy-subrc.
    WHEN 1.
      MESSAGE i049(sv) WITH sy-msgv1.
      sy-subrc = 1.
    WHEN 2.
      MESSAGE a050(sv) WITH view_name.
    WHEN 3.
      MESSAGE a037(sv) WITH view_name.
    WHEN 5.
      MESSAGE a028(sv) WITH view_name.
    WHEN 7.
      MESSAGE w054(sv) WITH sy-mandt.
      sy-subrc = 7.
  ENDCASE.
  rc = sy-subrc.
  IF exit_form NE space.
    PERFORM (exit_form) IN PROGRAM (sy-repid).
  ENDIF.
  IF e_act EQ 'E'.
    IF sy-subrc <> 0.
      vim_enq_s_u_rc = sy-subrc.
    ELSEIF rc <> 0.
      vim_enq_s_u_rc = rc.
    ELSE.
      vim_enq_s_u_rc = 0.
    ENDIF.
  ENDIF.
ENDFORM.

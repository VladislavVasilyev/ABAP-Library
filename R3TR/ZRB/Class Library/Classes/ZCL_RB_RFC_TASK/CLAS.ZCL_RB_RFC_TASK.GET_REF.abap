method GET_REF.

  field-symbols
     : <ls_rfc_rec> like line of dt_rfc_rec_task
     .

  read table dt_rfc_rec_task
       with table key task = task
       assigning <ls_rfc_rec>.

  check sy-subrc = 0.

  ref = <ls_rfc_rec>-var.

  clear <ls_rfc_rec>-var.

endmethod.

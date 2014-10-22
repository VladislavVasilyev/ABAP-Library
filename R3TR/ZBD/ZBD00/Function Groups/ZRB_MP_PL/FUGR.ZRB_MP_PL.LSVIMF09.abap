*---------------------------------------------------------------------*
*       FORM VIM_PROCESS_MESSAGE                                      *
*---------------------------------------------------------------------*
* process message depending on dialog mode                            *
*---------------------------------------------------------------------*
* VALUE(PM_ID)          ---> ID of message to send                    *
* VALUE(PM_ONLINE_TYPE) ---> message type used for online mode        *
* VALUE(PM_BATCH_TYPE)  ---> message type used for batch mode         *
* VALUE(PM_NBR)         ---> number of message to send                *
* VALUE(PM_V1)          ---> first mesage variable                    *
* VALUE(PM_V2)          ---> second mesage variable                   *
* VALUE(PM_V3)          ---> third mesage variable                    *
* VALUE(PM_V4)          ---> fourth mesage variable                   *
*---------------------------------------------------------------------*
FORM VIM_PROCESS_MESSAGE USING VALUE(PM_ID) LIKE SY-MSGID
                           VALUE(PM_ONLINE_TYPE) LIKE SY-MSGTY
                           VALUE(PM_BATCH_TYPE) LIKE SY-MSGTY
                           VALUE(PM_NBR)  LIKE SY-MSGNO
                           VALUE(PM_V1) LIKE SY-MSGV1
                           VALUE(PM_V2) LIKE SY-MSGV2
                           VALUE(PM_V3) LIKE SY-MSGV3
                           VALUE(PM_V4) LIKE SY-MSGV4.

  DATA: I_TYPE LIKE SPROT_U-SEVERITY, I_MSGTY LIKE SY-MSGTY,
        I_MSGNO LIKE SY-MSGNO,
        objtype TYPE ob_typ, objname TYPE ob_object.

  IF VIM_NO_DIALOG NE SPACE.           "no dialog - write protocol
    I_TYPE = I_MSGTY = PM_BATCH_TYPE. I_MSGNO = PM_NBR.
    IF VIM_IMPORT_PROFILE = 'X'.        "Profilimport
      IF vim_called_by_cluster NE 'X'.
         objname = VIM_VIEW_NAME.
        IF x_header-bastab EQ space.
        objtype = 'V'.
      ELSE.
        objtype = 'S'.
      ENDIF.
      ELSE.
        objname = vim_calling_cluster.
        objtype = 'C'.
      ENDIF.
      CALL FUNCTION 'SCPR_PROT_DATA_WRITE'
          EXPORTING
            act_id           = VIM_ACTOPTS-ACT_ID
            bcset_id         = VIM_BCSET_ID
            objectname       = objname
*           tablename        = object
*           tabletype        = tabtype
            tablekey         = VIM_PROFILE_ERRORKEY
            msgid            = PM_ID
            msgty            = I_TYPE
            msgno            = I_MSGNO
            var1             = PM_V1
            var2             = PM_V2
            var3             = PM_V3
            var4             = PM_V4
            objecttype       = objtype.
    ELSE.
      TRANSLATE I_TYPE USING 'I S '.
      CALL FUNCTION 'LCT_MESSAGE'
         EXPORTING
              IV_MSGID  = PM_ID
              IV_MSGTY  = I_TYPE
              IV_MSGNO  = I_MSGNO
              IV_MSGV1  = PM_V1
              IV_MSGV2  = PM_V2
              IV_MSGV3  = PM_V3
              IV_MSGV4  = PM_V4
              IV_DIALOG = SPACE.
    ENDIF.
    VIM_LAST_LOGGED_MESSAGE-ID = PM_ID.
    VIM_LAST_LOGGED_MESSAGE-TYPE = I_MSGTY.
    VIM_LAST_LOGGED_MESSAGE-NBR = PM_NBR.
    VIM_LAST_LOGGED_MESSAGE-V1 = PM_V1.
    VIM_LAST_LOGGED_MESSAGE-V2 = PM_V2.
    VIM_LAST_LOGGED_MESSAGE-V3 = PM_V3.
    VIM_LAST_LOGGED_MESSAGE-V4 = PM_V4.
    IF VIM_IMPORT_NO_MESSAGE EQ SPACE.
      MESSAGE ID PM_ID TYPE I_MSGTY NUMBER PM_NBR "to raise exception
                WITH PM_V1 PM_V2 PM_V3 PM_V4.
    ENDIF.
  ELSE.                                "with dialog - use pm_online_type
    I_MSGTY = PM_ONLINE_TYPE.
    MESSAGE ID PM_ID TYPE I_MSGTY NUMBER PM_NBR
              WITH PM_V1 PM_V2 PM_V3 PM_V4.
  ENDIF.                               "vim_no_dialog eq space
ENDFORM.                               "vim_process_message
*---------------------------------------------------------------------*
*       FORM VIM_BC_PROCESS_MESSAGE
*
*---------------------------------------------------------------------*
* process message depending on dialog mode                            *
*---------------------------------------------------------------------*
* VALUE(PM_ID)          ---> ID of message to send                    *
* VALUE(PM_ONLINE_TYPE) ---> message type used for online mode        *
* VALUE(PM_BATCH_TYPE)  ---> message type used for batch mode         *
* VALUE(PM_NBR)         ---> number of message to send                *
* VALUE(PM_V1)          ---> first mesage variable                    *
* VALUE(PM_V2)          ---> second mesage variable                   *
* VALUE(PM_V3)          ---> third mesage variable                    *
* VALUE(PM_V4)          ---> fourth mesage variable                   *
*---------------------------------------------------------------------*
FORM vim_bc_process_message USING value(pm_id) LIKE sy-msgid
                           value(pm_online_type) LIKE sy-msgty        "#EC NEEDED
                           value(pm_batch_type) LIKE sy-msgty
                           value(pm_nbr)  LIKE sy-msgno
                           value(pm_v1) LIKE sy-msgv1
                           value(pm_v2) LIKE sy-msgv2
                           value(pm_v3) LIKE sy-msgv3
                           value(pm_v4) LIKE sy-msgv4
                           value(objtype) TYPE ob_typ.

  DATA: i_type LIKE sprot_u-severity, i_msgty LIKE sy-msgty,
        i_msgno LIKE sy-msgno.

  i_type = i_msgty = pm_batch_type. i_msgno = pm_nbr.

  CALL FUNCTION 'SCPR_PROT_DATA_WRITE'
      EXPORTING
        act_id           = vim_actopts-act_id
        bcset_id         = vim_bcset_id
        objectname       = vim_view_name
*       tablename        = object
*       tabletype        = tabtype
        tablekey         = vim_profile_errorkey
        msgid            = pm_id
        msgty            = i_type
        msgno            = i_msgno
        var1             = pm_v1
        var2             = pm_v2
        var3             = pm_v3
        var4             = pm_v4
        objecttype       = objtype.
  vim_last_logged_message-id = pm_id.
  vim_last_logged_message-type = i_msgty.
  vim_last_logged_message-nbr = pm_nbr.
  vim_last_logged_message-v1 = pm_v1.
  vim_last_logged_message-v2 = pm_v2.
  vim_last_logged_message-v3 = pm_v3.
  vim_last_logged_message-v4 = pm_v4.
  IF vim_import_no_message EQ space.
    MESSAGE ID pm_id TYPE i_msgty NUMBER pm_nbr "to raise exception
              WITH pm_v1 pm_v2 pm_v3 pm_v4.
  ENDIF.
ENDFORM.                               "vim_bc_process_message

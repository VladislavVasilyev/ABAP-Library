method create_program.

  data
  : log_db type rglif-logdb
  , lr_x__call_module_error type ref to zcx_vcs__call_module_error
  .

*  move 'Lost in Translation' to i_s__prog-title.
  move i_s__prog-prog_inf-dbname to log_db.

  call method zcl_vcs_r3tr___tech=>rpy_program_insert
    exporting
      application         = i_s__prog-prog_inf-appl
      authorization_group = i_s__prog-prog_inf-auth_group
      edit_lock           = i_s__prog-prog_inf-edit_lock
      log_db              = log_db
      program_name        = i_s__prog-name
      program_type        = i_s__prog-prog_inf-prog_type
      temporary           = 'X'
      title_string        = i_s__prog-title
      save_inactive       = ' '
      source_extended     = i_s__prog-source.

*       DEVELOPMENT_CLASS         = '$TMP'
*       TRANSPORT_NUMBER          = ' '
*       R2_FLAG                   = ' '

  call method zcl_vcs_r3tr___tech=>rs_corr_insert
    exporting
      object          = i_s__prog-name
      object_class    = 'ABAP'
      mode            = 'I'
      devclass        = i_s__tadir-devclass
      author          = i_s__tadir-author
      genflag         = i_s__tadir-genflag
      program         = i_s__prog-name
      suppress_dialog = 'X'.

*      OBJECT_CLASS_SUPPORTS_MA       = ' '
*      EXTEND                         = ' '
*      MASTER_LANGUAGE                = ' '
*      KORRNUM                        = ' '
*      USE_KORRNUM_IMMEDIATEDLY       = ' '
*      GLOBAL_LOCK                    = ' '
*      OBJECT                         = pname(8)
*      MOD_LANGU                      = ' '
*     IMPORTING
*      DEVCLASS                       =
*      KORRNUM                        =
*      ORDERNUM                       =
*      NEW_CORR_ENTRY                 =
*      AUTHOR                         =
*      TRANSPORT_KEY                  =
*      NEW_EXTEND                     =

endmethod.

method zfm_get_bpc_lgf.

  call function 'ZFM_GET_BPC_LGF'
    exporting
      i_appset      = i_appset
      i_application = i_application
      i_filename    = i_filename
    importing
      e_doc         = e_doc
    tables
      et_lgf        = et_lgf
    exceptions
      not_existing  = 1
      others        = 3.

  mac__module_raise zfm_get_bpc_lgf
  : 1 not_existing
  , 3 others.

endmethod.

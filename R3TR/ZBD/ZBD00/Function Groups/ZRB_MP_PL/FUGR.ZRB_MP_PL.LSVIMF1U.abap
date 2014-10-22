*---------------------------------------------------------------------*
*       FORM VIM_ADDRESS_KEYTAB_ENTRIES_INTERN
*---------------------------------------------------------------------*
* create address related keytab entries (intern)
*---------------------------------------------------------------------*
FORM vim_addr_keytab_entries_intern
                          USING value(vakei_tabname) TYPE tabname
                                value(vakei_table)
                                value(vakei_keylen) TYPE i
                                value(vakei_action) TYPE sychar01
                                vakei_rc type sy-subrc.
  corr_keytab =  e071k.
  corr_keytab-objname = vakei_tabname.
  MOVE vakei_table TO corr_keytab-tabkey(vakei_keylen).
  vim_exit_11_12_active = 'X'.
  PERFORM update_corr_keytab USING vakei_action vakei_rc.
  CLEAR vim_exit_11_12_active.
ENDFORM. "vim_address_keytab_entries_intern

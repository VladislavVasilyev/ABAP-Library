method get_key_link.
  read table gd_t__reestr_link
       with table key id = id
       into link.
endmethod.

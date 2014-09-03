method get_script_line.

  clear: line, match.

  read table    gd_t__tokenlist
      index     index
      into      match.

  read table gd_t__logic index match-line
       into line.

endmethod.

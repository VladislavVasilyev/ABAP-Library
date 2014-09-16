method get_pathdevclas.

  data ld_v__devclass type devclass.

  ld_v__devclass = e_path = devclass.

  while 1 = 1.
    " check in sub devlcass
    select single parentcl
           from tdevc
           into ld_v__devclass
           where devclass = ld_v__devclass
             and parentcl <> ``.

    if sy-subrc = 0.
      concatenate ld_v__devclass `\` e_path into e_path.
    else.
      exit.
    endif.
  endwhile.



endmethod.

method crosssources.

  data
  : ld_v__devclass   type tdevc-devclass
  , ld_t__devclass   type standard table of tdevc-devclass
  , ld_t__tadir      type standard table of zvcst_s__tadir
  .

  field-symbols
  : <ld_s__devclass> like line of ld_t__devclass
  .

  refresh
  : e_t__tadir
  , ld_t__devclass
  .

  " check in sub devlcass
  select  devclass
    from  tdevc
    into table ld_t__devclass
    where parentcl = i_s__tadir-obj_name.

  append i_s__tadir-obj_name to ld_t__devclass.

  loop at ld_t__devclass
       assigning <ld_s__devclass>.

    select *
           from tadir
           appending corresponding fields of table ld_t__tadir
           where devclass  = <ld_s__devclass>
             and delflag  <> 'X'.

  endloop.

  insert lines of ld_t__tadir into table e_t__tadir.

endmethod.

method CROSSSOURCES.

  types: begin of tabap_glrefs_tag
         , name  type string
         , glref type line of scr_glrefs
         , tag   type scr_tag
         , end of tabap_glrefs_tag.

  data
  : ld_s__clskey type seoclskey
  , ld_v__name   type program
  , ld_s__tadir  type zvcst_s__tadir.

  move i_s__tadir-obj_name to ld_s__clskey-clsname.
  call function 'SEO_CLASS_GET_INCLUDE_BY_NAME'
    exporting
      clskey       = ld_s__clskey
      limu         = seok_r3tr_class
    importing
      progname     = ld_v__name.

* ABAP Compiler
  data
  : lr_o__abap_compiler type ref to cl_abap_compiler
  , ld_t__result        type scr_glrefs
  , ld_s__result        like line of ld_t__result
  , ld_v__tag           type scr_tag
  , abap_glrefs_tag     type tabap_glrefs_tag
  , abap_glrefs_tags    type standard table of tabap_glrefs_tag
  , ld_v__fname         type tfdir-pname
  .

  create object lr_o__abap_compiler
    exporting
      p_name = ld_v__name.

  call method lr_o__abap_compiler->get_all_refs
    exporting
      p_local  = ' '
    importing
      p_result = ld_t__result.


  loop at ld_t__result into ld_s__result.

    call method lr_o__abap_compiler->get_tag_of_full_name
      exporting
        p_full_name                = ld_s__result-full_name
      receiving
        p_tag                      = ld_v__tag
      exceptions
        include_not_found          = 1
        object_not_found           = 2
        program_fatal_syntax_error = 3
        others                     = 4.

    check sy-subrc = 0.

    move
    : ld_s__result-full_name+4 to abap_glrefs_tag-name
    , ld_s__result             to abap_glrefs_tag-glref
    , ld_v__tag                to abap_glrefs_tag-tag.
    if abap_glrefs_tag-name na '\:'.
      if abap_glrefs_tag-name(1) eq `Z`
      or abap_glrefs_tag-name(1) eq `Y`.

        case abap_glrefs_tag-tag.

          when 'TY'.                                          " Type
            select single *
                   from tadir
                   into corresponding fields of ld_s__tadir
                   where pgmid    eq zvcsc_r3tr
                     and obj_name eq abap_glrefs_tag-name.

          when 'FU'.                                         " Function
            move space to ld_v__fname(4).
            shift ld_v__fname left deleting leading space.
            select single *
                   from tadir
                   into corresponding fields of ld_s__tadir
                   where pgmid    eq zvcsc_r3tr
                     and object   eq zvcsc_r3tr_type-fugr
                     and obj_name eq ld_v__fname.
          when 'TP'.                                          " Typepool
            select single *
                   from tadir
                   into corresponding fields of ld_s__tadir
                   where pgmid    eq zvcsc_r3tr
                     and object   eq zvcsc_r3tr_type-type
                     and obj_name eq abap_glrefs_tag-name.
          when 'PR'.                                         " Program
            select single *
                   from tadir
                   into corresponding fields of ld_s__tadir
                   where pgmid    eq zvcsc_r3tr
                     and object   eq zvcsc_r3tr_type-prog
                     and obj_name eq abap_glrefs_tag-name.
        endcase.

        insert ld_s__tadir into table e_t__tadir.

      endif.
    endif.
    clear abap_glrefs_tag.
  endloop.

  free lr_o__abap_compiler.

endmethod.

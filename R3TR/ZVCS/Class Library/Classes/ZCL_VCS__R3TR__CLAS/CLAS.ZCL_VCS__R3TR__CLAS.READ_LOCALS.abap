method READ_LOCALS.

  data
  : ld_v__inctype          type seop_include_ext_app
  , ld_s_local             type ty_s__local
  , ld_t__default_source   type zvcst_t__char255
  .

*"* local class implementation for public class
*"* use this source file for the implementation part of
*"* local helper classes
*"* use this source file for any macro definitions you need
*"* in the implementation part of the class



  do 3 times.

    free: ld_s_local, ld_t__default_source.

    case sy-index.
      when 1.
        append
        :'*"* use this source file for any type declarations (class'      to ld_t__default_source
        ,'*"* definitions, interfaces or data types) you need for method' to ld_t__default_source
        ,'*"* implementation or private method''s signature'              to ld_t__default_source
        ,''                                                               to ld_t__default_source
        .
        move 'DEF' to ld_s_local-name.
        move seop_ext_class_locals_def to ld_v__inctype.
      when 2.
        append
        :'*"* local class implementation for public class'                to ld_t__default_source
        ,'*"* use this source file for the implementation part of'        to ld_t__default_source
        ,'*"* local helper classes'                                       to ld_t__default_source
        ,''                                                               to ld_t__default_source
        .
        move 'IMP' to ld_s_local-name.
        move seop_ext_class_locals_imp to ld_v__inctype.
      when 3.
        append
        :'*"* use this source file for any macro definitions you need'    to ld_t__default_source
        ,'*"* in the implementation part of the class'                    to ld_t__default_source
        ,''                                                               to ld_t__default_source
        .
        move 'MAC' to ld_s_local-name.
        move seop_ext_class_macros to ld_v__inctype.
    endcase.

    call method zcl_vcs_r3tr___lib__seo=>seo_class_get_include_source
      exporting
        clskey  = i_s__clskey
        inctype = ld_v__inctype
      importing
        source  = ld_s_local-source.

    if ld_s_local-source = ld_t__default_source.
      continue.
    endif.
    append ld_s_local to e_t__locals.

  enddo.
endmethod.

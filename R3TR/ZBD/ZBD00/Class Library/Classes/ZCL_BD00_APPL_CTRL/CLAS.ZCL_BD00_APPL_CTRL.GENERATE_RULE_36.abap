method generate_rule_36.

  data
  : mess                    type string
  , prog                    type string
  , lin                     type i
  , ld_t__code              like zcl_bd00_int_table=>cd_t__code
  , ld_v__classname         type string
  , ld_t__rule_link         type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , lr_o__class             type ref to zcl_bd00_int_table
  , ld_v__line              type string

  .

  field-symbols
  : <ld_s__reestr_36> type  zcl_bd00_int_table=>ty_s__reestr_36
  , <ld_s__class_reg> type  ty_s_class_reg
  .

  append `program.` to ld_t__code.
  append lines of zcl_bd00_int_table=>cd_t__code to ld_t__code.
  generate subroutine pool ld_t__code name prog message mess line lin.

  if sy-subrc <> 0.
    read table ld_t__code index lin into ld_v__line.

    raise exception type zcx_bd00_create_rule
      exporting message = mess
                line    = ld_v__line.
  endif.


  loop at zcl_bd00_int_table=>cd_t__reestr_36 assigning <ld_s__reestr_36>.

    concatenate `\PROGRAM=` prog <ld_s__reestr_36>-class  into ld_v__classname.

    read table gd_t__class_reg
      with table key id = <ld_s__reestr_36>-id
      assigning <ld_s__class_reg>.

    ld_t__rule_link   = zcl_bd00_appl_ctrl=>get_key_link( <ld_s__reestr_36>-id ) .

    create object lr_o__class
      type
        (ld_v__classname)
      exporting
        it_rule_link      = ld_t__rule_link
        it_reestr         = <ld_s__reestr_36>-t_object.

    case ld_t__rule_link-type.
      when zcl_bd00_int_table=>method-search.
        if ld_t__rule_link-default is bound.
          set handler lr_o__class->change_fline for ld_t__rule_link-default activation 'X'.
        endif.

        set handler lr_o__class->change_table for ld_t__rule_link-main activation 'X'.

      when zcl_bd00_int_table=>method-search.
    endcase.

    <ld_s__class_reg>-class ?= lr_o__class.
    free lr_o__class.

  endloop.


  refresh
  : zcl_bd00_int_table=>cd_t__code
  , zcl_bd00_int_table=>cd_t__reestr_36.

endmethod.

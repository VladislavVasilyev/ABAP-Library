method get_stack.

  data
  : gr_o__containers      type ref to zcl_bdnl_parser_container
  , lr_x__syntax          type ref to zcx_bdnl_syntax_error
  , ld_t__error           type table of string
  , ld_s__error           type string
  , ld_s__match           type zbnlt_s__match_res
  , ld_v__line            type string
  , ld_v__numline         type string
  , ld_v__offset          type string
  , ld_t__message         type uj0_t_message.
  .

  try.
*--------------------------------------------------------------------*
      stack = get_stack1( ).
*--------------------------------------------------------------------*
    catch zcx_bdnl_syntax_error into lr_x__syntax.

      concatenate `Syntax error in script: ` cr_o__cursor->gd_v__script_path `.` into ld_s__error.
      append ld_s__error to ld_t__error.
      write / ld_s__error.

      call method cr_o__cursor->get_script_line
        exporting
          index = lr_x__syntax->index
        importing
          match = ld_s__match
          line  = ld_v__line.

      replace all occurrences of cl_abap_char_utilities=>horizontal_tab in ld_v__line with ` `.

      ld_v__numline = ld_s__match-line.
      ld_v__offset  = ld_s__match-offset.

      concatenate `Line ` ld_v__numline `, Pos ` ld_v__offset `: "` ld_v__line `".` into ld_s__error.

      append ld_s__error to ld_t__error.
      write / ld_s__error.

      ld_s__error = lr_x__syntax->get_text( ).
      append ld_s__error to ld_t__error.
      write / ld_s__error.

      raise exception type zcx_bdnl_parser
            exporting errortab = ld_t__error.
  endtry.
*--------------------------------------------------------------------*

endmethod.

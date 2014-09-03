method read_source.

  data
  : lr_x__module_error type ref to zcx_vcs__call_module_error
  , abap_source_format type ref to cl_wb_abap_source_format
  , target_source type swbse_max_line_tab
  , w_target_source like line of target_source
  , w_source type zvcst_s__char255
  , error_text type string.

* Initialisieren
  free: e_t__source, e_v__lines_truncated.

* Source lesen
  try.
      create object abap_source_format
        exporting
          progname           = i_v__name
          line_width         = swbse_c_max_line_width "swbse_c_norm_line_width
        exceptions
          not_exists         = 1
          illegal_line_width = 2
          others             = 3.

      mac__module_raise abap_source_format
      : 1 not_existing
      , 2 illegal_line_width
      , 3 others
      .

      call method abap_source_format->convert
        exporting
          truncate_single_lines      = space
          convert_despite_all_errors = space
        importing
          target_source              = target_source
          lines_truncated            = e_v__lines_truncated
        exceptions
          not_convertable            = 1
          not_scanable               = 2
          others                     = 3.

      mac__module_raise abap_source_format
      : 1 not_convertable
      , 2 not_scanable
      , 3 others
      .

      loop at target_source into w_target_source.
        move w_target_source to w_source.
        append w_source to e_t__source.
      endloop.

* Hat es zu lange Zeilen ?
      call method abap_source_format->is_containing_too_long_lines
        importing
          is_long = e_f__long.

    catch zcx_vcs__call_module_error into lr_x__module_error.
      raise exception type zcx_vcs__call_module_error
      exporting previous  = lr_x__module_error
                exception = lr_x__module_error->exception
                module    = zcx_vcs__call_module_error=>mod-read_source.
  endtry.

endmethod.

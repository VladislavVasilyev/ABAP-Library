method GET_LOG_STAT.

    case is_rw_log-type.
      when cs-log_read_full  or cs-log_read_pack.
        res =  '->['.
      when cs-log_write_full or cs-log_write_pack.
        res =  '<-['.
      when cs-log_transf_pack.
    endcase.

    if is_rw_log-st_rec-nr_fail > 0.
      concatenate res 'X]' into res.
    else.
      concatenate res 'O]' into res.
      condense res no-gaps.
    endif.

endmethod.

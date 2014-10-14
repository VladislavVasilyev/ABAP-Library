method create_select.

  if gd_s__param-appset_id eq zblnc_keyword-bp.
    e_f__create =  create__bp( i_v__package_size ).
  else.
    if gd_s__param-appl_id is not initial.
      if gd_s__param-appl_id = zblnc_keyword-generate.
        e_f__create = create__bpcgen( i_v__package_size ).
      else.
        e_f__create = create__bpc( i_v__package_size ).
      endif.
    elseif gd_s__param-dimension is not initial.
      e_f__create = create__bpcdim( ).
    endif.
  endif.

endmethod.

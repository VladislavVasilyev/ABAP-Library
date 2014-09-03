method get_infocube.

  cd_s__infocube-flag = abap_true.
  cd_s__infocube-name = i_infocube.
  cd_s__infocube-kyf = it_kyf_list.

  create object e_infocube
    exporting
      i_type_pk        = i_type_pk
      it_alias         = it_alias
      it_range         = it_range
      it_dim_list      = it_dim_list
      if_suppress_zero = if_suppress_zero
      i_packagesize    = i_packagesize.

  clear: cd_s__infocube.

endmethod.

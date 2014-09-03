method READ_METHOD_DETAIL.

  data
  : begin of seo_method_get_detail
  , cpdkey type seocpdkey
  , method type vseomethod
  , method_details type seoo_method_details
  , end of seo_method_get_detail
  .

  free method_details.

  seo_method_get_detail-cpdkey-clsname = method-clsname.
  seo_method_get_detail-cpdkey-cpdname = method-cmpname.

  call method zcl_vcs_r3tr___lib__seo=>seo_method_get_detail
    exporting
      cpdkey         = seo_method_get_detail-cpdkey
    importing
      method         = seo_method_get_detail-method
      method_details = method_details.

endmethod.

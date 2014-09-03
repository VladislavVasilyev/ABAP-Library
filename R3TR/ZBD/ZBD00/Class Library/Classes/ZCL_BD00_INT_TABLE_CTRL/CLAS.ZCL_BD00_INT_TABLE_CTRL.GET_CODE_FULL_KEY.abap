method GET_CODE_FULL_KEY.
     data
       : lv_name type string
       , lv_code type string
       .

    field-symbols
       : <lv_key>  type abap_keydescr
       .
    lv_name = name. condense lv_name no-gaps.

    loop at io_model->gd_s__handle-tab-tech_name->key
         assigning <lv_key>.

      concatenate <lv_key> ` = ` lv_name `-` <lv_key> into lv_code.

      if sy-tabix < lines( io_model->gd_s__handle-tab-tech_name->key ).
        concatenate lv_code ` and` into lv_code.
      else.
        concatenate lv_code `.` into lv_code.
      endif.

      concatenate `       ` lv_code into lv_code.

      translate lv_code to lower case.

      append lv_code to code.
      clear lv_code.
    endloop.

endmethod.

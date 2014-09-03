method download.

  data
  : lr_o__me type ref to zcl_vcs___xml_txt.


  if i_s__source-xmlsource is bound.
    create object lr_o__me
      exporting
        i_s__source = i_s__source.

    call method
    : lr_o__me->tab2xml
    , lr_o__me->xml2fxml
    , lr_o__me->write_to_xmlfile
    , lr_o__me->write_to_txtfile
    .
  endif.

  e_t__message = lr_o__me->gd_t__message.

endmethod.

method tab2xml.

  data
  : ld_v__name          type string
  , ld_v__retcode       type sysubrc
  , ld_i__node          type ref to if_ixml_node
  , ld_o__structdescr   type ref to cl_abap_structdescr
  , ld_v__nodename      type string
  , ld_v__value         type string
  .

  field-symbols
  : <ld_s__structdescr> type abap_compdescr
  , <data>              type any
  , <value>             type any
  , <header>            type any
  .

  assign gd_s__source-xmlsource->* to <data>.

  ld_v__name = `HEADER`.
  gd_s__source-header-id = 0.

  ld_v__value = gd_s__source-type.

   ld_v__retcode = gr_o__xmldoc->create_with_data( name = ld_v__value dataobject = <data> ).

  " insert dir
  ld_i__node ?= gr_o__xmldoc->m_document->get_first_child( ).

  ld_i__node->get_name( ).

  ld_i__node = gr_o__xmldoc->m_document->create_simple_element(
                      name   = ld_v__name
                      parent = ld_i__node ).

  ld_o__structdescr ?= cl_abap_structdescr=>describe_by_data( gd_s__source-header ) .

  assign gd_s__source-header to <header>.

  loop at ld_o__structdescr->components
       assigning <ld_s__structdescr>
       where name <> `ID`.

    assign component <ld_s__structdescr>-name of structure <header> to <value>.
    ld_v__value    = <value>.
    ld_v__nodename = <ld_s__structdescr>-name.
    check not ld_v__value is  initial.

    gr_o__xmldoc->m_document->create_simple_element(
      name = ld_v__nodename
      value = ld_v__value
      parent = ld_i__node ).
  endloop.

  " insert head

*  zvcst_s__head
*.

***  ld_i__node ?= gr_o__xmldoc->m_document->get_first_child( ).
***
***  ld_i__node->get_name( ).

***  ld_i__node = gr_o__xmldoc->m_document->create_simple_element(
***      name = `HEAD`
***      parent = ld_i__node ).
***
***  gr_o__xmldoc->m_document->create_simple_element(
***            name = `SYSTEM`
***            value = gd_s__source-header-system
***            parent = ld_i__node ).
***
***  gr_o__xmldoc->m_document->create_simple_element(
***          name = `TYPE`
***          value = gd_s__source-head-type
***          parent = ld_i__node ).
***
***  gr_o__xmldoc->m_document->create_simple_element(
***          name = `NAME`
***          value = gd_s__source-head-name
***          parent = ld_i__node ).

endmethod.

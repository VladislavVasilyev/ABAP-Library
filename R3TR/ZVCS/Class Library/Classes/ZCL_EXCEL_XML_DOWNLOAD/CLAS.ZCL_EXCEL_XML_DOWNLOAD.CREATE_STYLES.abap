method create_styles.

  data
  : lr_i__style           type ref to if_ixml_element
  , lr_i__format          type ref to if_ixml_element
  , lr_i__borders         type ref to if_ixml_element
  .


* Header row - Yellow, Bold
  set_simp_el> lr_i__style   'Style' `` gr_i__styles.
  set_attr_ns> lr_i__style   `ss`    `ID` `Header`.
  set_simp_el> lr_i__format  `Font`  `` lr_i__style.
  set_attr_ns> lr_i__format  `ss`  `Bold` `1`.
  set_simp_el> lr_i__format  'Interior' `` lr_i__style.
  set_attr_ns> lr_i__format  `ss` 'Color' '#FFFF00'.
  set_attr_ns> lr_i__format  `ss` 'Pattern' 'Solid'.
  set_simp_el> lr_i__format  'Alignment' `` lr_i__style.
  set_attr_ns> lr_i__format  `ss` `Vertical` `Bottom`.
  set_attr_ns> lr_i__format  `ss` `WrapText` `1`.


  " First column
  set_simp_el> lr_i__style    `Style` `` gr_i__styles.
  set_attr_ns> lr_i__style    `ss` `ID` `Firstcolumn`.
  set_simp_el> lr_i__borders  `Borders`  `` lr_i__style.
  set_simp_el> lr_i__format   `Border` `` lr_i__borders.
  set_attr_ns> lr_i__format   `ss` `Position`  `Bottom`.
  set_attr_ns> lr_i__format   `ss` `LineStyle` `Continuous`.
  set_attr_ns> lr_i__format   `ss` `Weight`    `1`.

  set_simp_el> lr_i__format   `Border` `` lr_i__borders.
  set_attr_ns> lr_i__format   `ss` `Position`  `Left`.
  set_attr_ns> lr_i__format   `ss` `LineStyle` `Continuous`.
  set_attr_ns> lr_i__format   `ss` `Weight`    `1`.

  set_simp_el> lr_i__format   `Border` `` lr_i__borders.
  set_attr_ns> lr_i__format   `ss` `Position`  `Right`.
  set_attr_ns> lr_i__format   `ss` `LineStyle` `Continuous`.
  set_attr_ns> lr_i__format   `ss` `Weight`    `1`.

  set_simp_el> lr_i__format   `Border` `` lr_i__borders.
  set_attr_ns> lr_i__format   `ss` `Position`  `Top`.
  set_attr_ns> lr_i__format   `ss` `LineStyle` `Continuous`.
  set_attr_ns> lr_i__format   `ss` `Weight`    `1`.

  set_simp_el> lr_i__format  `Interior` `` lr_i__style.
  set_attr_ns> lr_i__format  `ss` `Color`   `#F2F2F2`.
  set_attr_ns> lr_i__format  `ss` `Pattern` `Solid`.

endmethod.

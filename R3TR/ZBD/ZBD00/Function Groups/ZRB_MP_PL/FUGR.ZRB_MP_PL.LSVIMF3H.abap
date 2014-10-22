*---------------------------------------------------------------------*
*       FORM F4_POSITIONIEREN                                         *
*---------------------------------------------------------------------*
*       called externally from POPUP_GET_VALUES_USER_HELP             *
*---------------------------------------------------------------------*
form f4_positionieren using value(tabname) type tabname
                            value(fieldname) type fieldname
                            value(display)
                      changing returncode
                               value type any.
  statics: field_tab type table of dfies initial size 20.

  data: tabval(132) type c,
        v_tab like table of tabval initial size 500,
        w_dfies type dfies,
        return_tab type table of ddshretval initial size 1,
        begin of out_conv_function,
         prefix(16) type c value 'CONVERSION_EXIT_',
         exit like vimnamtab-convexit,
         suffix(7) type c value '_OUTPUT',
        end of out_conv_function,
        f4_length type i,    "total length of to be displayed fields
        progname type sy-repid,
        value_bef_f4 type help_info-fldvalue.

  data: begin of  dynpfields  occurs 1.                     "BEGIN GKPR/1020911
          include structure dynpread.
  data: end of dynpfields.
  data: sy_repid like sy-repid,
        sy_dynnr like sy-dynnr.                             "END GKPR/1020911

  field-symbols: <hf1>, <dfies> type dfies, <retval> type ddshretval.

  move 'SAPLSPO4' to sy_repid.                              "BEGIN GKPR/1020911
* BEGIN 563161 2008/DUTTAN/08.07.2008
* move '0300' to sy_dynnr.
  move sy-dynnr to sy_dynnr.
* END 563161 2008
  move 'SVALD-VALUE' to dynpfields-fieldname.
*  dynpfields-stepl = 1.                                   "GKPR/1021700
  append dynpfields.
  call function 'DYNP_VALUES_READ'
            exporting
              dyname                         = sy_repid
              dynumb                         = sy_dynnr
*             TRANSLATE_TO_UPPER             = ' '
*             REQUEST                        = ' '
*             PERFORM_CONVERSION_EXITS       = ' '
*             PERFORM_INPUT_CONVERSION       = ' '
*             DETERMINE_LOOP_INDEX           = ' '
            tables
              dynpfields                     = dynpfields
           exceptions
              invalid_abapworkarea           = 1
              invalid_dynprofield            = 2
              invalid_dynproname             = 3
              invalid_dynpronummer           = 4
              invalid_request                = 5
              no_fielddescription            = 6
              invalid_parameter              = 7
              undefind_error                 = 8
              double_conversion              = 9
              stepl_not_found                = 10
              others                         = 11.
  if sy-subrc <> 0.
    message i089(ec).
  endif.

  if sy-subrc eq 0.
    read table dynpfields index 1.
    move: dynpfields-fieldvalue to value_bef_f4.
  endif.                                                    "END GKPR/1020911

  read table field_tab index 1 assigning <dfies>.
  if sy-subrc <> 0 or <dfies>-tabname <> x_header-maintview.
    refresh field_tab.

* xb  06.02 csn ext.237151 2002, BCEK061005 ---------begin----------
* check the total display length of F4-List
    f4_length = 0.
    if x_header-tablen > 1000.
      loop at x_namtab.
        if x_header-clidep ne space.       "ignore client field
          check sy-tabix ne 1.
        endif.
        if x_namtab-keyflag ne space or    "all key fields or
           x_namtab-datatype eq 'CHAR' and "all possibly text fields
           x_namtab-flength  ge 10     and
           x_namtab-lowercase  ne space.

          f4_length = f4_length + x_namtab-outputlen.
        endif.
      endloop.
    endif.

    if f4_length < 1000.          "check the fields length
* xb  06.02 csn ext.237151 2002, BCEK061005 ----------end-----------
      loop at x_namtab.
        if x_header-clidep ne space.       "ignore client field
          check sy-tabix ne 1.
        endif.
        check x_namtab-readonly <> vim_hidden.                  "Subviews
        if x_header-bastab ne space and x_header-texttbexst ne space.
          check x_namtab-keyflag ne space and   "all entity keyfields
                x_namtab-texttabfld eq space or                 "or
            x_namtab-keyflag eq space and   "all texttab function fields
                x_namtab-texttabfld ne space.
        else.
          check x_namtab-keyflag ne space or    "all key fields or
               x_namtab-datatype eq 'CHAR' and "all possibly text fields
                x_namtab-flength  ge 10     and
                x_namtab-lowercase  ne space.
        endif.
        if x_namtab-texttabfld ne space.
          w_dfies-tabname = x_header-texttab.
        else.
          w_dfies-tabname = x_header-maintview.              "Subviews
        endif.
        w_dfies-fieldname = x_namtab-viewfield.
        append w_dfies to field_tab.
      endloop.
    else.
* xb  06.02 csn ext.237151 2002, BCEK061005 ---------begin----------
      message i810(sv) with x_header-viewname.
*   Die gesamte Länge der View & ist mehr als 1000 Charakter. Nur Key
*   Field wird gezeigt.
      loop at x_namtab.
        if x_header-clidep ne space.       "ignore client field
          check sy-tabix ne 1.
        endif.
        check x_namtab-readonly <> vim_hidden.                  "Subviews
        if x_header-bastab ne space and x_header-texttbexst ne space.
          check x_namtab-keyflag ne space and   "all entity keyfields
                x_namtab-texttabfld eq space or                 "or
            x_namtab-keyflag eq space and   "all texttab function fields
                x_namtab-texttabfld ne space.
        else.
          check x_namtab-keyflag ne space.    "all key fields
        endif.
        if x_namtab-texttabfld ne space.
          w_dfies-tabname = x_header-texttab.
        else.
          w_dfies-tabname = x_header-maintview.              "Subviews
        endif.
        w_dfies-fieldname = x_namtab-viewfield.
        append w_dfies to field_tab.
      endloop.
* xb  06.02 csn ext.237151 2002, BCEK061005 ----------end-----------
    endif.
  endif.


  loop at extract.
    loop at field_tab assigning <dfies>.
      read table x_namtab with key viewfield = <dfies>-fieldname.
      if x_header-bastab ne space and x_header-texttbexst ne space.
        if x_namtab-keyflag eq space and x_namtab-texttabfld ne space.
* Type S: text field
          assign component x_namtab-viewfield
           of structure <vim_ext_txt_struc> to <hf1>.
        elseif x_namtab-keyflag ne space
         and x_namtab-texttabfld eq space.
* Type S: key field
          assign component x_namtab-viewfield
           of structure <vim_extract_struc> to <hf1>.
        endif.
      else.
* viewfield
        assign component x_namtab-viewfield
         of structure <vim_extract_struc> to <hf1>.
      endif.
      check <hf1> is assigned.
*        IF X_HEADER-BASTAB NE SPACE AND X_HEADER-TEXTTBEXST NE SPACE.
*          CHECK X_NAMTAB-KEYFLAG NE SPACE AND   "all entity keyfields
*                X_NAMTAB-TEXTTABFLD EQ SPACE OR             "or
*                X_NAMTAB-KEYFLAG EQ SPACE AND   "all texttab function
*                X_NAMTAB-TEXTTABFLD NE SPACE.
*        ENDIF.
*        ASSIGN EXTRACT+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH) TO <HF1>
*               TYPE 'C'.
      write <hf1> to tabval(x_namtab-outputlen).
      append tabval to v_tab.
      clear tabval.
    endloop.
  endloop.
*  "HCG Look first in valuetable of tables  for V_TCURR (Performance)
*  "HCG Special handling due to cust issues 272054/2003 or 130305/2000
  if x_header-viewname = 'V_TCURR'.
    read table x_namtab with key viewfield = fieldname.
    call function 'F4IF_FIELD_VALUE_REQUEST'
            exporting
                tabname             = x_namtab-bastabname
                fieldname           = fieldname
*            SEARCHHELP          = ' '
*            SHLPPARAM           = ' '
*            dynpprog            = progname
*            dynpnr              = dynnr
*            dynprofield         = ' '
*            stepl               = dynp_stepl
             value               = value_bef_f4             "GKPR/1020911
*            MULTIPLE_CHOICE     = ' '
*            DISPLAY             = ' '
*            SUPPRESS_RECORDLIST = ' '
*              callback_program    = progname
*              callback_form       = 'CALLBACK_F4'
           tables
                return_tab          = return_tab
           exceptions
                field_not_found     = 1
                no_help_for_field   = 2
                inconsistent_help   = 3
                no_values_found     = 4
                others              = 5.
    case sy-subrc.
      when 0.
        read table return_tab index 1 assigning <retval>.
        if sy-subrc = 0.
          value = <retval>-fieldval.
        endif.
      when 2.
*     should not happen for V_TCURR
    endcase.
  else.
    call function 'F4IF_INT_TABLE_VALUE_REQUEST'
      exporting
*     DDIC_STRUCTURE         = ' '
        retfield               = fieldname
*     PVALKEY                = ' '
*     DYNPPROG               = ' '
*     DYNPNR                 = ' '
*     DYNPROFIELD            = ' '
*     STEPL                  = 0
*     WINDOW_TITLE           =
      value                  = value_bef_f4                 "GKPR/1020911
*     VALUE_ORG              = 'C'
*     MULTIPLE_CHOICE        = ' '
        display                = display
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     MARK_TAB               =
      tables
        value_tab              = v_tab
        field_tab              = field_tab
        return_tab             = return_tab
*     DYNPFLD_MAPPING        =
      exceptions
        parameter_error        = 1
        no_values_found        = 2
        others                 = 3.
    if sy-subrc = 0.
      read table return_tab index 1 assigning <retval>.
      if sy-subrc = 0.
        value = <retval>-fieldval.
      endif.
    else.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.
endform.                               "f4_positionieren

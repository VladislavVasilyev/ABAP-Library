method rs_dd_tygr_insert_sources.

  data
  : ld_v__subrc like sy-subrc
  , begin of ld_s__ddenq                  "DICT/TYPE-Sperrschlüssel
    , objtype type rsdeo-objtype
    , objname type rsdeo-objname
    , end of ld_s__ddenq.
  .

  perform tygr_check in program saplsd31 using typegroupname '' ld_v__subrc. "löst Ausnahmen aus
  if ld_v__subrc ne 0.
    exit.
  endif.

  if ddtext is initial.  "Kurztext ist obligatorisch
*    message s005(e2) raising object_not_specified.
    exit.
  endif.

*--------------------------------------------------------------------*
* tygr_add_check_insert
*  perform tygr_add_check_insert tables source
*  using typegroupname 'X' corrnum devclass ddtext
*  changing subrc.
*--------------------------------------------------------------------*
  type-pools sedi.

  constants
  : inclprefix(3) value '%_C'.

  types
  : begin of t_obj_def
    , ddxx type dd50d
    , fld_tb type sedi_source
    , end of t_obj_def.

  data
  : objname type e071-obj_name
  , malangu like sy-langu
  , transp_key type trkey
  , progname like sy-repid
  , progdir type progdir

  , df type t_obj_def
  .

  clear ld_v__subrc.
  ld_s__ddenq-objtype = 'TYPE'.
  ld_s__ddenq-objname = typegroupname.
*{ Sperren- und Berechtigungsprüfung, Kunden-Exit
  call function 'RS_ACCESS_PERMISSION'
    exporting
      authority_check         = 'X'
      global_lock             = 'X'
      mode                    = 'INSERT'
      object                  = ld_s__ddenq
      object_class            = 'DICT'
      suppress_corr_check     = ' '
      suppress_language_check = ' '
    importing  " modification_language is new_master_language
      modification_language   = malangu
      transport_key           = transp_key
    exceptions
      canceled_in_corr        = 03
      locked_by_author        = 01
      permission_failure      = 01
      others                  = 02.

  if sy-subrc ne 0.
    case sy-subrc.
*            1 -> Meldung wird vom Korrektursystem ausgegeben
      when 2.
*        message id sy-msgid type 'S'
*           number sy-msgno with sy-msgv1 sy-msgv2
*           sy-msgv3 sy-msgv4
*        raising permission_failure.
      when 3.                          "Aktion abbrechen
*        message s004(e2)  raising not_executed.
    endcase.
    ld_v__subrc = 4.
    exit.
  else.                                "Kunden-Exit
    clear sy-subrc.                    "vor dem Aufruf des Kunden-Exits!
    call function 'RS_DD_EXIT'
      exporting
        objectname = ld_s__ddenq-objname
        objtype    = ld_s__ddenq-objtype
        operation  = 'A'
      exceptions
        cancelled  = 1
        others     = 2.
    if sy-subrc ne 0.
      call function 'RS_DD_DEQUEUE'
        exporting
          objtype = ld_s__ddenq-objtype
          objname = ld_s__ddenq-objname.
      if not sy-msgid is initial.
*        message id     sy-msgid
*                type   'I'
*                number sy-msgno
*                with   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*        raising not_executed.
      else.
*        message i029(e2) raising not_executed.
      endif.
      ld_v__subrc = 4.
      exit.
    endif.
  endif.

*{ TRDIR-Eintrag und Programmsource für das Typgruppen-Include hinzufügen
  concatenate inclprefix typegroupname into progname.
  insert report progname from source state 'A'.
  select single * from  progdir
         into corresponding fields of progdir
         where  name   = progname
         and    state  = 'A'
         .
  unpack sy-mandt  to progdir-rmand.
  progdir-cnam       = sy-uname.
  progdir-cdat       = sy-datum.
  progdir-levl       = sy-saprl.
  progdir-subc       = srext_type_pool.  "Programmtyp T = Typgruppe
  progdir-name       = progname.
  progdir-state      = 'A'.
  progdir-uccheck    = 'X'."df-ddxx-uccheck.
  update progdir from progdir.

  data ddtypet type ddtypet.

  ddtypet-typegroup = TYPEGROUPNAME.
  ddtypet-ddlanguage = malangu.
  ddtypet-ddtext    = ddtext.                                 "#EC *
  modify ddtypet from ddtypet.

*  call function 'RS_WORKING_AREA_ACTIVE_CHECK'
*    exceptions
*      nok    = 1
*      others = 2.
  if sy-subrc = 0.
*    insert report progname from source state 'I'.
*    progdir-state      = 'I'.
*    update progdir from progdir.
*    objname = typegroupname.
*    call function 'RS_INSERT_INTO_WORKING_AREA'
*      exporting
*        object   = zvcsc_r3tr_type-type
*        obj_name = objname
*      exceptions
*        others   = 0.
  endif.
*  message s010  with typegroupname.    "& wurde o. P. gesichert

* Zusatzinclude für die Laufzeit hinzufügen
  perform create_ext_include in program saplsd31 using typegroupname df-ddxx-uccheck.
*}
* Baum-Knoten hinzufügen
  call function 'RS_TREE_OBJECT_PLACEMENT'
    exporting
      object    = typegroupname
      operation = 'INSERT'
      type      = 'CDG'.

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
  call function 'RS_DD_DEQUEUE'        "Entsperren
       exporting
            objtype = ld_s__ddenq-objtype
            objname = ld_s__ddenq-objname.

endmethod.

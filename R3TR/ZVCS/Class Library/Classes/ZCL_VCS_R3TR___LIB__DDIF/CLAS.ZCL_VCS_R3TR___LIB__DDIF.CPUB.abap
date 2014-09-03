class ZCL_VCS_R3TR___LIB__DDIF definition
  public
  final
  create public .

*"* public components of class ZCL_VCS_R3TR___LIB__DDIF
*"* do not include other source files here!!!
public section.
  type-pools SEOC .
  type-pools SEOK .
  type-pools SEOO .
  type-pools SEOR .
  type-pools SEOS .
  type-pools SEOT .
  type-pools ZVCSC .
  type-pools ZVCST .

  types:
    begin of tables
      , dd28j type standard table of dd28j with non-unique default key
      , dd05m type standard table of dd05m with non-unique default key
      , dd36m type standard table of dd36m with non-unique default key
      , dd03p type standard table of dd03p with non-unique default key
      , dd27p type standard table of dd27p with non-unique default key
      , dd32p type standard table of dd32p with non-unique default key
      , dd07v type standard table of dd07v with non-unique default key
      , dd08v type standard table of dd08v with non-unique default key
      , dd12v type standard table of dd12v with non-unique default key
      , dd17v type standard table of dd17v with non-unique default key
      , dd26v type standard table of dd26v with non-unique default key
      , dd28v type standard table of dd28v with non-unique default key
      , dd31v type standard table of dd31v with non-unique default key
      , dd33v type standard table of dd33v with non-unique default key
      , dd35v type standard table of dd35v with non-unique default key
      , dd42v type standard table of dd42v with non-unique default key
      , ddtypet type standard table of ddtypet with non-unique default key
      , end of tables .

  class-methods DDIF_DTEL_PUT
    importing
      !NAME type DDOBJNAME
      !DD04V_WA type DD04V optional
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_SHLP_PUT
    importing
      !NAME type DDOBJNAME
      !DD30V_WA type DD30V optional
      !DD31V_TAB type TABLES-DD31V
      !DD32P_TAB type TABLES-DD32P
      !DD33V_TAB type TABLES-DD33V .
  class-methods DDIF_DOMA_PUT
    importing
      !NAME type DDOBJNAME
      !DD01V_WA type DD01V
      !DD07V_TAB type TABLES-DD07V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_VIEW_PUT
    importing
      !NAME type DDOBJNAME
      !DD25V_WA type DD25V optional
      !DD09L_WA type DD09V optional
      !DD26V_TAB type TABLES-DD26V
      !DD27P_TAB type TABLES-DD27P
      !DD28J_TAB type TABLES-DD28J
      !DD28V_TAB type TABLES-DD28V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TABL_PUT
    importing
      !NAME type DDOBJNAME
      !DD02V_WA type DD02V optional
      !DD09L_WA type DD09V optional
      !DD03P_TAB type TABLES-DD03P
      !DD05M_TAB type TABLES-DD05M
      !DD08V_TAB type TABLES-DD08V
      !DD35V_TAB type TABLES-DD35V
      !DD36M_TAB type TABLES-DD36M
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_DOMA_GET
    importing
      !NAME type DDOBJNAME
      !STATE type DDOBJSTATE default 'A'
      !LANGU type SY-LANGU default ' '
    exporting
      !GOTSTATE type DDGOTSTATE
      !DD01V_WA type DD01V
      !DD07V_TAB type TABLES-DD07V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_DTEL_GET
    importing
      !NAME type DDOBJNAME
      !STATE type DDOBJSTATE default 'A'
      !LANGU type SY-LANGU default ''
    exporting
      !GOTSTATE type DDGOTSTATE
      !DD04V_WA type DD04V
      !TPARA_WA type TPARA
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_SHLP_GET
    importing
      !NAME type DDOBJNAME
      !STATE type DDOBJSTATE default 'A'
      !LANGU type SY-LANGU default ' '
    exporting
      !GOTSTATE type DDGOTSTATE
      !DD30V_WA type DD30V
      !DD31V_TAB type TABLES-DD31V
      !DD32P_TAB type TABLES-DD32P
      !DD33V_TAB type TABLES-DD33V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TABL_GET
    importing
      !NAME type DDOBJNAME
      !STATE type DDOBJSTATE default 'A'
      !LANGU type SY-LANGU default ' '
    exporting
      !GOTSTATE type DDGOTSTATE
      !DD02V_WA type DD02V
      !DD09L_WA type DD09V
      !DD03P_TAB type TABLES-DD03P
      !DD05M_TAB type TABLES-DD05M
      !DD08V_TAB type TABLES-DD08V
      !DD12V_TAB type TABLES-DD12V
      !DD17V_TAB type TABLES-DD17V
      !DD35V_TAB type TABLES-DD35V
      !DD36M_TAB type TABLES-DD36M
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TABL_ACTIVATE
    importing
      !NAME type DDOBJNAME
      value(PRID) type SY-TABIX default -1
    exporting
      !RC type SY-SUBRC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_DTEL_ACTIVATE
    importing
      !NAME type DDOBJNAME
      value(PRID) type SY-TABIX default -1
      !AUTH_CHK type DDBOOL_D default 'X'
    exporting
      !RC type SY-SUBRC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_SHLP_ACTIVATE
    importing
      !NAME type DDOBJNAME
      value(PRID) type SY-TABIX default -1
    exporting
      !RC type SY-SUBRC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_DOMA_ACTIVATE
    importing
      !NAME type DDOBJNAME
      value(PRID) type SY-TABIX default -1
      value(AUTH_CHK) type DDBOOL_D default 'X'
    exporting
      !RC type SY-SUBRC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TTYP_ACTIVATE
    importing
      !NAME type DDOBJNAME
      value(PRID) type SY-TABIX default -1
    exporting
      !RC type SY-SUBRC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_VIEW_ACTIVATE
    importing
      !NAME type DDOBJNAME
      value(PRID) type SY-TABIX default -1
      value(AUTH_CHK) type DDBOOL_D default 'X'
    exporting
      !RC type SY-SUBRC
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TTYP_GET
    importing
      !NAME type DDOBJNAME
      !STATE type DDOBJSTATE default 'A'
      !LANGU type SY-LANGU default ' '
    exporting
      !GOTSTATE type DDGOTSTATE
      !DD40V_WA type DD40V
      !DD42V_TAB type TABLES-DD42V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TTYP_PUT
    importing
      !NAME type DDOBJNAME
      !DD40V_WA type DD40V
      !DD42V_TAB type TABLES-DD42V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_TYPE_GET
    importing
      !NAME type TRDIR-NAME
      !STATE type DDOBJSTATE default 'A'
    exporting
      !SOURCE type ZVCST_T__CHAR255
      !TEXTS type TABLES-DDTYPET
    raising
      ZCX_VCS__CALL_MODULE_ERROR .
  class-methods DDIF_VIEW_GET
    importing
      !NAME type DDOBJNAME
      !STATE type DDOBJSTATE default 'A'
      !LANGU type SY-LANGU default SY-LANGU
    exporting
      !GOTSTATE type DDGOTSTATE
      !DD25V_WA type DD25V
      !DD09L_WA type DD09V
      !DD26V_TAB type TABLES-DD26V
      !DD27P_TAB type TABLES-DD27P
      !DD28J_TAB type TABLES-DD28J
      !DD28V_TAB type TABLES-DD28V
    raising
      ZCX_VCS__CALL_MODULE_ERROR .

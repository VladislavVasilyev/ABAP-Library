TYPE-POOL ZCONS .

CONSTANTS
  :   ZCONS_STR_NULL(1) type c value ''
  .

CONSTANTS " константы консолидации
  : BEGIN OF ZCONS_FL
    , M20501 type string value 'FL_M20501'
    , M20502 type string value 'FL_M20502'
    , M20503 type string value 'FL_M20503'
    , M20504 type string value 'FL_M20504'
    , M20505 type string value 'FL_M20505'
    , M20506 type string value 'FL_M20506'
    , M20507 type string value 'FL_M20507'
    , M20508 type string value 'FL_M20508'
    , M20509 type string value 'FL_M20509'
    , M20510 type string value 'FL_M20510'
    , M20511 type string value 'FL_M20511'
    , M20512 type string value 'FL_M20512'
    , M20514 type string value 'FL_M20514'
    , M20515 type string value 'FL_M20515'
    , M20516 type string value 'FL_M20516'
    , C      type string value 'FL_C'
    , O      type string value 'FL_O'
    , SHT    type string value 'FL_SHT'
    , TTLT   type string value 'FL_TTLT'
    , TRANSL type string value 'TRANSL'
  , END OF ZCONS_FL
  , BEGIN OF ZCONS_LOANS
    , BEGIN OF R
      , BEGIN OF lt
        , princ type string value 'LT_LOANS_R_PRINC'
        , comm  type string value 'LT_LOANS_R_COMM'
      , END OF lt
      , BEGIN OF st
        , princ type string value 'ST_LOANS_R_PRINC'
        , comm  type string value 'ST_LOANS_R_COMM'
      , END of st
    , END OF R
    , BEGIN OF O
      , BEGIN OF NC
        , PRINC type string value 'NC_LOANS_O_PRINC'
      , END OF NC
      , BEGIN OF CA
        , PRINC type string value 'CA_LOANS_O_PRINC'
      , END OF CA
    , END OF O
  , END OF ZCONS_LOANS
  , BEGIN OF ZCONS_AC
    , 17_CF type string value 'AC_17_CF'
    , 21_CF type string value 'AC_21_CF'
  , END OF ZCONS_AC
  .

*--------------------------------------------------------------------*
CONSTANTS:
  zcons_bw_debug_user type string value 'ZBW_DEBUG_USER'.

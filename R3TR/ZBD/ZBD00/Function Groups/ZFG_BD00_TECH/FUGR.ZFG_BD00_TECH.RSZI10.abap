*----------------------------------------------------------------------*
*   INCLUDE RSZI10
*
*   collects all types and constants for general OCX handling
*----------------------------------------------------------------------*

TYPES:
     RSZ_OCX_CLASS_ID(30)              TYPE C,
     RSZ_OCX_EVENT_ID                  TYPE I,
     RSZ_OCX_TABLE_NAME(30)            TYPE C,
     RSZ_OCX_CBFORM_NAME(30)           TYPE C,
     RSZ_OCX_PROP_NAME                 LIKE TYPEINFO-VERB.

TYPES:
     RSZ_DEST               LIKE RFCHOSTS-RFCDEST.

CONSTANTS:
     RSZ_C_NOT_IMPORTED     TYPE I  VALUE -2100000.

TYPES:
     RSZ_TEXTELEMENT        LIKE TEXTPOOL-ENTRY.

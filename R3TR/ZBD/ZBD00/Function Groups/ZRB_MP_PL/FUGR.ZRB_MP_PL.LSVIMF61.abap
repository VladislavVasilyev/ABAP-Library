*&---------------------------------------------------------------------*
*&  Include           LSVIMF61
**&---------------------------------------------------------------------
*
*&---------------------------------------------------------------------*
*&      Form  MAP_TEXTTABKEY_TO_VIEWKEY
*&---------------------------------------------------------------------*
* Texttabellen-Schlüssel aus Transportauftrag in zugehörigen
* View-/Primärtabellenschlüssel transformieren
*----------------------------------------------------------------------*
* --> NAMTAB
* --> HEADER
* --> TEXTTABKEY     Importschlüssel der Texttabelle
*$$$ Release 5.0: included in HEADER $$$
* --> SPRASFDPOS     Offset des Sprachenschlüssels
*$$$
* --> TEXTTAB_KEYLEN Länge des zu berücksichtigenden Schlüsselteils
*                    (i.A. tatsächliche Schlüssellänge,
*                    bei generischem Transport: nichtgen. Schlüsselteil)
* --> IS_GENERIC_KEY 'X' => Texttabellen-Schlüssel is generisch
*
* <-- VIEWKEY        View/Primärtabellenschlüssel
* <-- MAP_ERROR      'X' -> Fehler bei der Abb., VIEWKEY nicht gefüllt
*                    (nur bei GENKEY = 'X' relevant)
*----------------------------------------------------------------------*
FORM map_texttabkey_to_viewkey TABLES namtab STRUCTURE vimnamtab
                               USING  header TYPE vimdesc
                                      texttabkey TYPE x
                                      texttab_keylen TYPE syfleng
                                      is_generic_key TYPE xfeld
                               CHANGING viewkey TYPE x
                                        map_error.
  DATA: o1 TYPE i, o2 TYPE i,
        t_keylen TYPE i, l TYPE i, h_viewkey TYPE tabl8000.
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab,
                 <texttab_struc> TYPE ANY,
                 <texttab_fld> TYPE ANY,
                 <txt_struc> TYPE ANY,
                 <viewfld> TYPE ANY.

  CLEAR: map_error, viewkey.

  ASSIGN: texttabkey TO <texttab_struc> CASTING TYPE (header-texttab),
          h_viewkey TO <txt_struc> CASTING TYPE (header-maintview).
  MOVE viewkey TO h_viewkey.
  IF is_generic_key = space.
*  IF is_generic_key = space.
    LOOP AT namtab ASSIGNING <namtab>
      WHERE keyflag <> space AND txttabfldn <> space.
      ASSIGN: COMPONENT <namtab>-viewfield OF STRUCTURE <txt_struc>
               TO <viewfld>,
              COMPONENT <namtab>-txttabfldn
               OF STRUCTURE <texttab_struc> TO <texttab_fld>.
      <viewfld> = <texttab_fld>.
    ENDLOOP.
* "HCG HW723732 fill additional view-keyfields with dataset value
* CustMSG 20963/2004 otherwise # will be stored in these view-keyfields
    IF header-bastab NE 'X'.             "Only neccessary in view case
      LOOP AT namtab ASSIGNING <namtab>
           WHERE keyflag <> space AND txttabfldn EQ space.
        ASSIGN: COMPONENT <namtab>-viewfield OF STRUCTURE <txt_struc>
                 TO <viewfld>.
*  value for additional view-keyfield must specified unique in sellist
*  otherwise SE11 view-definition is wrong
        READ TABLE dba_sellist WITH KEY viewfield = <namtab>-viewfield.
        MOVE dba_sellist-value TO <viewfld>.
      ENDLOOP.
    ENDIF.
  ELSE.
    IF header-sprasfdpos < texttab_keylen.
* Sprache im nichtgen. Teil
      t_keylen = texttab_keylen - vim_spras_length.
    ELSE.
      t_keylen = texttab_keylen.
    ENDIF.
    LOOP AT namtab ASSIGNING <namtab>
*      WHERE keyflag = space AND texttabfld = 'X'.
      WHERE keyflag <> space AND txttabfldn <> space.
      o1 = <namtab>-position + <namtab>-flength.
      o2 = <namtab>-texttabpos + <namtab>-flength.
      ASSIGN: COMPONENT <namtab>-viewfield OF STRUCTURE <txt_struc>
               TO <viewfld>,
              COMPONENT <namtab>-txttabfldn
               OF STRUCTURE <texttab_struc> TO <texttab_fld>.
      IF o1 <= t_keylen AND o2 <= texttab_keylen.
        <viewfld> = <texttab_fld>.
      ELSEIF o1 > t_keylen AND o2 > texttab_keylen. "gen. Teil
        IF <namtab>-position < t_keylen
         AND <namtab>-texttabpos < texttab_keylen
         AND 'CNDT' CS <namtab>-inttype.
          l = ( texttab_keylen - <namtab>-texttabpos )
              DIV cl_abap_char_utilities=>charsize.
          <viewfld>(l) = <texttab_fld>(l).
        ENDIF.
      ELSE.
        map_error = 'X'. EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  MOVE h_viewkey TO viewkey.
*  LOOP AT namtab WHERE keyflag = 'X' AND txttabfldn <> space.
*    IF is_generic_key = space.
*      viewkey+namtab-position(namtab-flength) =
*         texttabkey+namtab-texttabpos(namtab-flength).
*    ELSE.
*      IF sprasfdpos < texttab_keylen.   "Sprache im nichtgen. Teil
*        t_keylen = texttab_keylen - vim_spras_length.
*      ELSE.
*        t_keylen = texttab_keylen.
*      ENDIF.
*      o1 = namtab-position + namtab-flength.
*      o2 = namtab-texttabpos + namtab-flength.
*      IF o1 <= t_keylen AND o2 <= texttab_keylen.
*        viewkey+namtab-position(namtab-flength) =
*          texttabkey+namtab-texttabpos(namtab-flength).
*      ELSEIF o1 > t_keylen AND o2 > texttab_keylen. "gen. Teil
*        IF namtab-position < t_keylen AND
*           namtab-texttabpos < texttab_keylen.
*          l = texttab_keylen - namtab-texttabpos.
*          viewkey+namtab-position(l) = texttabkey+namtab-texttabpos(l).
*        ENDIF.
*      ELSE.
*        map_error = 'X'. EXIT.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
ENDFORM.                    " MAP_TEXTTABKEY_TO_VIEWKEY

*&--------------------------------------------------------------------*
*&      Form  MAP_VIEWKEY_TO_TEXTTABKEY                               *
*&--------------------------------------------------------------------*
* Schlüssel von Texttabelle anhand des View-/Tabellenschlüssels und
* der Sprache zusammensetzen
*&--------------------------------------------------------------------*
* --> X_NAMTAB
* --> VIEW_WA  WA of view                                             *
* --> SPRAS    Sprachschlüssel                                        *
* <-- TEXT_WA  Key of text table                                      *
*&--------------------------------------------------------------------*
FORM map_viewkey_to_texttabkey TABLES namtab STRUCTURE vimnamtab
                                USING header TYPE vimdesc
                                      spras LIKE t002-spras
                                      view_wa TYPE x
                             CHANGING text_wa TYPE x.

  DATA: align TYPE f,                                          "#EC NEEDED
        h_view_wa TYPE tabl8000,
        h_texttab_wa TYPE tabl8000.

  FIELD-SYMBOLS: <namtab> TYPE vimnamtab,
                 <texttab_struc> TYPE ANY,
                 <texttab_fld> TYPE ANY,
                 <view_struc> TYPE ANY,
                 <viewfld> TYPE ANY.

  ASSIGN h_texttab_wa TO <texttab_struc> CASTING TYPE (header-texttab).
  MOVE: text_wa TO h_texttab_wa,
        view_wa TO h_view_wa.
* Sprachschlüssel
  ASSIGN COMPONENT header-sprasfield OF STRUCTURE <texttab_struc>
   TO <texttab_fld>.
  <texttab_fld> = spras.
*  text_wa+spras_pos(vim_spras_length) = spras.
* Schlüsselfelder der Text-Tabelle
  ASSIGN: h_view_wa(header-tablen) TO <view_struc>
             CASTING TYPE (header-maintview).
  LOOP AT namtab ASSIGNING <namtab>
    WHERE txttabfldn <> space AND keyflag <> space.
    ASSIGN: COMPONENT <namtab>-viewfield OF STRUCTURE <view_struc>
             TO <viewfld>,
            COMPONENT <namtab>-txttabfldn
             OF STRUCTURE <texttab_struc> TO <texttab_fld>.
    <texttab_fld> = <viewfld>.
  ENDLOOP.
  MOVE h_texttab_wa TO text_wa.
*  LOOP AT namtab WHERE txttabfldn <> space AND keyflag <> space.
*    text_wa+namtab-texttabpos(namtab-flength) =
*         view_wa+namtab-position(namtab-flength).
*  ENDLOOP.
ENDFORM.                               " MAP_VIEWKEY_TO_TEXTTABKEY

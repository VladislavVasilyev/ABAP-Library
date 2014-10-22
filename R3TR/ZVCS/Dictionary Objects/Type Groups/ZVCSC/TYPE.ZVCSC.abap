type-pool zvcsc .

constants: begin of zvcsc_xml
           , txtsource type string value `TXTSOURCE`
           , filename  type string value `item`
           , end of zvcsc_xml.

constants  zvcsc_r3tr type pgmid value `R3TR`.

constants: begin of zvcsc_filetype
           , txt  type string value `TXT`
           , abap type string value `ABAP`
           , xml  type string value `XML`
           , end of zvcsc_filetype.

constants: begin of zvcsc_r3tr_type
           , clas type trobjtype value `CLAS`
           , intf type trobjtype value `INTF`
           , dtel type trobjtype value `DTEL`
           , doma type trobjtype value `DOMA`
           , tabl type trobjtype value `TABL`
           , view type trobjtype value `VIEW`
           , ttyp type trobjtype value `TTYP`
           , fugr type trobjtype value `FUGR`
           , msag type trobjtype value `MSAG`
           , type type trobjtype value `TYPE`
           , shlp type trobjtype value `SHLP`
           , prog type trobjtype value `PROG`
           , devc type trobjtype value `DEVC`
           , enhs type trobjtype value `ENHS`
           , enho type trobjtype value `ENHO`
           , end of zvcsc_r3tr_type.

constants: begin of zvcsc_tabclass_type
           , transp  type tabclass value `TRANSP`
           , inttab  type tabclass value `INTTAB`
           , cluster type tabclass value `CLUSTER`
           , pool    type tabclass value `POOL`
           , view    type tabclass value `VIEW`
           , append  type tabclass value `APPEND`
           , end of zvcsc_tabclass_type.

constants: begin of zvcsc_r3tr_path
           , clas type string value `Class Library\Classes`
           , intf type string value `Class Library\Interfaces`
           , prog type string value `Programs`
           , fugr type string value `Function Groups`
           , dtel type string value `Dictionary Objects\Data Elements`
           , doma type string value `Dictionary Objects\Domains`
           , ttyp type string value `Dictionary Objects\Table Types`
           , type type string value `Dictionary Objects\Type Groups`
           , shlp type string value `Dictionary Objects\Srch Helps`
           , view type string value `Dictionary Objects\Views`
           , msag type string value `Message Classes`
           , end of zvcsc_r3tr_path.

constants: begin of zvcsc_tabclass_path
           , transp  type string value `Dictionary Objects\Database Tables`
           , cluster type string value `Dictionary Objects\Database Tables`
           , pool    type string value `Dictionary Objects\Database Tables`
           , append  type string value `Dictionary Objects\Structures`
           , inttab  type string value `Dictionary Objects\Structures`
           , view    type string value `Dictionary Objects\Views`
           , end of zvcsc_tabclass_path.

*--------------------------------------------------------------------*
* BPC Object
*--------------------------------------------------------------------*
constants  zvcsc_bpc(4) type c value `BPCS`.

constants: begin of zvcsc_bpc_type
           , apps type trobjtype value `APPS`
           , appl type trobjtype value `APPL`
           , dimn type trobjtype value `DIMN`
           , sclo type trobjtype value `SCLO`
           , pack type trobjtype value `PACK`
           , xltp type trobjtype value `XLTP`
           , excl type trobjtype value `EXCL`
           , end of zvcsc_bpc_type.

constants: begin of zvcsc_bpc_path
           , sclo type string value `Script Logic`
           , pack type string value `Packages`
           , xltp type string value `Excel Templates`
           , end of zvcsc_bpc_path.

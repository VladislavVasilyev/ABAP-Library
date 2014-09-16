class ZCL_VCS__BPCS__XLTP definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__BPCS__XLTP
*"* do not include other source files here!!!
public section.

  types:
    ty_t__doc_content type standard table of uj_string with non-unique default key .
  types:
    begin of ty_s__xltp
      , appset             type uj_appset_id           "SAP BusinessObjects - Ид. набора приложений
      , application        type uj_appl_id             "SAP BusinessObjects - Ид. приложения
      , filename           type uj_docname
      , docname            type uj_docname             "BPC: имя папки/документа
      , docdesc            type uj_docdesc             "BPC: описание документа
      , doctype            type uj_doctype             "BPC: вид документа
      , owner              type uj_owner               "BPC: ответственный за документ
      , create_date        type uj_create_date         "BPC: создать дату
      , create_time        type uj_create_time         "BPC: создать время
      , lstmod_date        type uj_lstmod_date         "BPC: дата последнего изменения
      , lstmod_time        type uj_lstmod_time         "BPC: время последнего изменения
      , lstmod_user        type uj_lstmod_user         "BPC: автор последнего изменения
      , lock_ind           type uj_lock_ind
      , doc_length         type uj_doc_length
      , begin of doc_tree
        , dir_doc          type uj_dir_doc             "BPC: каталог/документ
        , parentdoc        type uj_docname             "BPC: имя папки/документа
        , zippeddoc        type uj_docname             "BPC: имя папки/документа
      , end of doc_tree
      , doc_content        type uj_doc_content
*      , doc_contentt       type ty_t__doc_content
      , doc_content_db     type uj_doc_content_db
      , content            type string
      , end of ty_s__xltp .
  types:
    begin of ty_s__content
     , filename           type string
     , content            type standard table of x255 with non-unique default key
     , file_length        type i
     , end of ty_s__content .
  types:
    begin of ty_s__source
     , source            type zvcst_s__download
     , content           type ty_s__content
     , end of ty_s__source .

  types: begin of ty_s__checkobj_xltp.
  include type zvcs_st__bpcsxltp.
  types: checkbox(1) type  c
         , index(4) type c
         , end of ty_s__checkobj_xltp.


  class-data CD_V__APPSET_ID type UJ_APPSET_ID .

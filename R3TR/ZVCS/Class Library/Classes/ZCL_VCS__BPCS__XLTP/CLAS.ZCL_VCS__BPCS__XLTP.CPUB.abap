*----------------------------------------------------------------------*
*       CLASS ZCL_VCS__BPCS__XLTP  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zcl_vcs__bpcs__xltp definition
  public
  inheriting from zcl_vcs_objects_stack
  final
  create public .

*"* public components of class ZCL_VCS__BPCS__XLTP
*"* do not include other source files here!!!
  public section.

    types: ty_t__doc_content type standard table of uj_string with non-unique default key.


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
               , lock_ind	          type uj_lock_ind
               , doc_length	        type uj_doc_length
               , begin of doc_tree
                 , dir_doc       type uj_dir_doc             "BPC: каталог/документ
                 , parentdoc     type uj_docname             "BPC: имя папки/документа
                 , zippeddoc     type uj_docname             "BPC: имя папки/документа
               , end of doc_tree
               , doc_content        type uj_doc_content
               , doc_contentt       type ty_t__doc_content
               , doc_content_db     type uj_doc_content_db
               , end of ty_s__xltp .


    class-data cd_v__appset_id type uj_appset_id.            " Copy to appset

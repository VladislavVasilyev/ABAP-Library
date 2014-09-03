class ZCL_VCS__BPCS__SCLO definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__BPCS__SCLO
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__sclo
             , appset          type uj_appset_id           "SAP BusinessObjects - Ид. набора приложений
             , application     type uj_appl_id             "SAP BusinessObjects - Ид. приложения
             , filename        type uj_docname
             , docname         type uj_docname             "BPC: имя папки/документа
             , docdesc         type uj_docdesc             "BPC: описание документа
             , doctype         type uj_doctype             "BPC: вид документа
             , owner           type uj_owner               "BPC: ответственный за документ
             , create_date     type uj_create_date         "BPC: создать дату
             , create_time     type uj_create_time         "BPC: создать время
             , lstmod_date     type uj_lstmod_date         "BPC: дата последнего изменения
             , lstmod_time     type uj_lstmod_time         "BPC: время последнего изменения
             , lstmod_user     type uj_lstmod_user         "BPC: автор последнего изменения
             , source          type zvcst_t__lgfsource     "BPC: текст
             , end of ty_s__sclo .

  class-data CD_V__APPSET_ID type UJ_VALUE .

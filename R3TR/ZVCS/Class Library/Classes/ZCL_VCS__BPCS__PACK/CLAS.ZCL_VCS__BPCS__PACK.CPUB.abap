class ZCL_VCS__BPCS__PACK definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__BPCS__PACK
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__langu
        , langu type spras
        , package_desc type uj_desc
        , end of ty_s__langu .
  types:
    ty_t__langu type sorted table of ty_s__langu with unique key langu .
  types:
    begin of ty_s__pack
        , appset_id     type uj_appset_id   " sap businessobjects - ид. набора приложений
        , app_id        type uj_appl_id     " sap businessobjects - ид. приложения
        , team_id       type uj_team_id     " bpc: ид. группы
        , group_id      type uj_pack_grp_id " bpc: ид. группы пакетов
        , package_id    type uj_package_id  " bpc: ид. пакета
        , chain_id      type rspc_chain     " цепочка процесса
        , package_type  type uj_pack_type   " bpc: вид пакета
        , user_group    type uj_user_group  " bpc: группа пользователей (вид задачи)
        , langu         type ty_t__langu
        , source        type table of string with non-unique default key
        , end of ty_s__pack .

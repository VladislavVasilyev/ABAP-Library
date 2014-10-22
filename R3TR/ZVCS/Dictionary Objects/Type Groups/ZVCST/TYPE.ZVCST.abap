type-pool zvcst .

types zvcst_s__char255    type c length 255.
types zvcst_t__char255    type standard table of zvcst_s__char255 with non-unique default key.
types zvcst_s__source     type string.
types zvcst_t__source     type standard table of zvcst_s__source with non-unique default key.
types zvcst_r__xmlsource  type ref to data.


types: begin of zvcst_s__object
       , pgmid  type pgmid              " Идентификатор программы в запросах и задачах
       , object type trobjtype          " Тип объекта
       , end of zvcst_s__object.

types: begin of zvcst_s__tadir
       , pgmid type pgmid               " Идентификатор программы в запросах и задачах
       , object type trobjtype          " Тип объекта
       , obj_name type string           " Имя объекта в каталоге объектов
       , korrnum type trkorr_old        " Запрос/Задача по версию 3.0 включительно
       , srcsystem type srcsystem	      " Система оригинала объекта
       , author	type responsibl	        " Ответственный за объект репозитария
       , srcdep	type repair	            " Индикатор исправления объекта репозитария
       , devclass	type devclass	        " Пакет
       , genflag type genflag           " Индикатор генерации
       , edtflag type edtflag           " Флаг возможности редактирования объекта в спец. редакторе
       , cproject	type cproject	        " Внутреннее использование
       , masterlang	type masterlang	    " Язык оригинала в объектах репозитария
       , versid type versionid          " Внутреннее использование
       , paknocheck	type paknocheck	    " Индикатор исключения для проверки пакета
       , objstablty	type objstablty	    " Статус деблокирования объекта разработки
       , component type dlvunit	        " Компонент ПО
       , crelease	type saprelease	      " Версия R/3
       , delflag type objdelflag        " Индикатор удаления
       , translttxt	type translttxt	    " Перевод технических текстов на язык разработки
       , tabclass type tabclass         " Тип таблицы
       , pathdevc type string
       , appset type uj_appset_id       " Ид. набора приложений BPC
       , application type uj_appl_id    " Ид. прилодения BPC
       , id type i                      " Идентификатор
       , end of zvcst_s__tadir
       .
types zvcst_t__tadir   type sorted table of zvcst_s__tadir
                            with unique key pgmid object obj_name appset application.

types: begin of zvcst_s__xml_appendstruct
       , name   type string
       , source type ref to data
       , end of zvcst_s__xml_appendstruct
       .

types: begin of zvcst_s__head
       , system type string
       , type   type string
       , name   type string
       , end of zvcst_s__head
       .

types: begin of zvcst_s__source_path
       , pathnode   type string
       , pathname   type string
       , end of zvcst_s__source_path
       , zvcst_t__source_path type standard table of zvcst_s__source_path
                                   with non-unique default key.

types: begin of zvcst_s__download
       , type           type zvcst_s__object
       , mastername     type string
       , xmlname        type string
       , extsrcname     type string
       , xmlsource      type zvcst_r__xmlsource
       , txtnodepath    type zvcst_t__source_path
       , path           type string
       , header         type zvcst_s__tadir
       , end of zvcst_s__download
       .

types: zvcst_t__download type standard table of zvcst_s__download
                         with non-unique default key.

types: begin of zvcst_s__upload
       , type         type zvcst_s__object
       , xmlsource    type zvcst_r__xmlsource
       , header       type zvcst_s__tadir
       , end of zvcst_s__upload
       .

types: zvcst_t__upload type standard table of zvcst_s__upload
                         with non-unique default key.


types: begin of zvcst_s__objects_stack
       , type   type zvcst_s__object
       , object type ref to object
       , error  type rs_bool
       , end of zvcst_s__objects_stack.

types: zvcst_t__objects_stack type sorted table of zvcst_s__objects_stack with unique key type.

*types: begin of zvcst_s__task_stack
*       , id       type i
*       , system   type string
*       , type     type string
*       , name     type string
*       , tadir    type zvcst_s__tadir
*       , end of zvcst_s__task_stack.
*
*types: zvcst_t__task_stack type sorted table of zvcst_s__task_stack with non-unique default key.

*--------------------------------------------------------------------*
* R3TR Object
*--------------------------------------------------------------------*
types: begin of zvcst_s__r3tr_obj
       , pgid      type pgmid
       , type	     type trobjtype
       , obj_range type range of tadir-obj_name
       , end of zvcst_s__r3tr_obj.

types zvcst_t__r3tr_obj type standard table of zvcst_s__r3tr_obj.

types: begin of zvcst_s__file_source
       , filename   type string
       , source     type zvcst_t__source
       , end of zvcst_s__file_source.

types: begin of zvcst_s__path
       , path       type localfile
       , directory  type string
       , prefix     type string
       , f_sys      type rs_bool
       , f_pac      type rs_bool
       , f_dir      type rs_bool
       , f_ele      type rs_bool
       , end of zvcst_s__path
       , zvcst_t__file_source type standard table of zvcst_s__file_source
                                   with non-unique default key.

types: begin of zvcst_s__r3tr_objdownload
       , tadir      type zvcst_s__tadir
       , refsource  type zvcst_r__xmlsource
       , txtsource  type zvcst_t__source_path
       , path       type string
       , end of zvcst_s__r3tr_objdownload
       , zvcst_t__r3tr_objdownload type standard table of zvcst_s__r3tr_objdownload
                                         with non-unique default key.

types: begin of zvcst_s__r3tr_objupload
       , sequence   type i
       , tadir      type zvcst_s__tadir
       , refsource  type zvcst_r__xmlsource
       , end of zvcst_s__r3tr_objupload
       , zvcst_t__r3tr_objupload type standard table of zvcst_s__r3tr_objupload
                                      with non-unique default key.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* BPC Object
*--------------------------------------------------------------------*
types: zvcst_t__appset       type range of uj_appset_id.
types: zvcst_t__application  type range of uj_appl_id.
types: zvcst_t__dimension    type range of uj_dim_name.

types zvcst_s__lgfsource type uj_string.
types zvcst_t__lgfsource type standard table of zvcst_s__lgfsource
                              with non-unique default key.

*--------------------------------------------------------------------*
*XML
*--------------------------------------------------------------------*
types: begin of zvcst_s__sequence
       , sequence type i
       , field    type string
       , end of zvcst_s__sequence.

types zvcst_t__sequence type standard table of zvcst_s__sequence with non-unique default key.

types: begin of zvcst_s__xmlworksheet
       , name                 type string
       , table                type ref to data
       , sequence             type zvcst_t__sequence
       , f__filter            type rs_bool
       , f__validtextlength   type rs_bool
       , f__splitvertical     type rs_bool
       , end of zvcst_s__xmlworksheet.

types: zvcst_t__xmlworksheet type standard table of zvcst_s__xmlworksheet with non-unique default key.

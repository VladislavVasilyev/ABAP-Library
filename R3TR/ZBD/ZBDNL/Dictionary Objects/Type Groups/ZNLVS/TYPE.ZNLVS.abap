TYPE-POOL ZNLVS .

*--------------------------------------------------------------------*
* 2014.04.17
*--------------------------------------------------------------------*

**********************************************************************
* Vs. 0.0.1 - формализация синтаксиса для создания внутренних контейнеров
*     создание стандартной таблицы со всеми полями
*     SELECT *
*            FROM   BUDGET_2014~GROSSMARGIN
*            INTO   TableName.
*
*     создание сортировочной таблицы с частично не уникальным ключем, сортировка по умолчанию
*     в порядке следования полей в скобках
*
*     SELECT NUK    ( SCENARIO TIME ACCOUNT ENTITY ) PRODUCT~CATEGORY PRODUCT
*            FROM   BUDGET_2014~GROSSMARGIN
*            INTO   TableName.
*
*     создание сортировочной таблицы с полностью не уникальным ключем, сортировка по умолчанию
*     в порядке следования полей после объявления SELECT NUK
*
*     SELECT NUK 	  SCENARIO TIME ACCOUNT ENTITY PRODUCT~CATEGORY PRODUCT
*            FROM   BUDGET_2014~GROSSMARGIN
*            INTO   TableName.
*
*     создание хэшированой таблицы только полный ключ
*
*     SELECT UK	    SCENARIO TIME ACCOUNT ENTITY PRODUCT~CATEGORY PRODUCT
*            FROM   BUDGET_2014~GROSSMARGIN
*            INTO   TableName.
**********************************************************************
